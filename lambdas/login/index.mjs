import {
  CognitoIdentityProviderClient,
  AdminInitiateAuthCommand,
  AdminGetUserCommand,
  UserNotFoundException
} from '@aws-sdk/client-cognito-identity-provider'

const cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' })
const CLIENT_ID = process.env.CLIENT_ID
const USER_POOL_ID = process.env.USER_POOL_ID

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body)
    const { document } = body

    if (!document) {
      return formatResponse(400, {
        message: 'Document is required'
      })
    }

    // 1. Check if exist
    try {
      const getUserCommand = new AdminGetUserCommand({
        UserPoolId: USER_POOL_ID,
        Username: document
      })

      const userResult = await cognitoClient.send(getUserCommand);

      // 2. Auth
      const authCommand = new AdminInitiateAuthCommand({
        UserPoolId: USER_POOL_ID,
        ClientId: CLIENT_ID,
        AuthFlow: 'ADMIN_USER_PASSWORD_AUTH',
        AuthParameters: {
          USERNAME: document,
          PASSWORD: `${document}@Temp`
        }
      });

      const authResult = await cognitoClient.send(authCommand)

      if (!authResult.AuthenticationResult?.AccessToken) {
        throw new Error('Auth error')
      }

      const customerData = userResult.UserAttributes?.reduce((acc, attr) => {
        if (attr.Name && attr.Value) acc[attr.Name] = attr.Value
        return acc
      }, {})

      return formatResponse(200, {
        tokenId: authResult.AuthenticationResult.IdToken,
        accessToken: authResult.AuthenticationResult.AccessToken,
        refreshToken: authResult.AuthenticationResult.RefreshToken,
        expiresIn: authResult.AuthenticationResult.ExpiresIn,
        customer: {
          document: document,
          name: customerData.name,
          email: customerData.email,
        }
      })
    } catch (error) {
      if (error instanceof UserNotFoundException) {
        return formatResponse(404, {
          message: 'Customer not found'
        })
      }
      throw error
    }

  } catch (error) {
    console.error('Login error:', error);
    return formatResponse(500, {
      message: 'Internal server error'
    })
  }
}

const formatResponse = (code, body) => ({
  statusCode: code,
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(body)
})
