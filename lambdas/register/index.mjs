import {
  CognitoIdentityProviderClient,
  AdminCreateUserCommand,
  AdminSetUserPasswordCommand,
  UsernameExistsException,
  AdminInitiateAuthCommand
} from '@aws-sdk/client-cognito-identity-provider'

const cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' })
const CLIENT_ID = process.env.CLIENT_ID
const USER_POOL_ID = process.env.USER_POOL_ID

const generateTempPassword = () => Math.random().toString(36).substring(2, 15) + '@1A'

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body)
    const { name, email, document } = body

    if (!name || !email || !document) {
      return formatResponse(400, {
        message: 'Required data is missing'
      })
    }

    // 1. Create user in Cognito
    const createUserCommand = new AdminCreateUserCommand({
      UserPoolId: USER_POOL_ID,
      Username: document,
      UserAttributes: [
        { Name: 'email', Value: email },
        { Name: 'name', Value: name },
        { Name: 'custom:document', Value: document }
      ],
      TemporaryPassword: generateTempPassword(),
      MessageAction: 'SUPPRESS' // Don't send confirmation email
    })

    await cognitoClient.send(createUserCommand)

    // 2. Set permanent password
    const userPassword = `${document}@Temp`
    const setPasswordCommand = new AdminSetUserPasswordCommand({
      UserPoolId: USER_POOL_ID,
      Username: document,
      Password: userPassword,
      Permanent: true
    })

    await cognitoClient.send(setPasswordCommand);

    // 3. Auth > Generate auth tokens
    const authCommand = new AdminInitiateAuthCommand({
      UserPoolId: USER_POOL_ID,
      ClientId: CLIENT_ID,
      AuthFlow: 'ADMIN_USER_PASSWORD_AUTH',
      AuthParameters: {
        USERNAME: document,
        PASSWORD: userPassword
      }
    });

    const authResult = await cognitoClient.send(authCommand)

    if (!authResult.AuthenticationResult?.AccessToken) {
      throw new Error('Auth error')
    }

    return formatResponse(200, {
      tokenId: authResult.AuthenticationResult.IdToken,
      accessToken: authResult.AuthenticationResult.AccessToken,
      refreshToken: authResult.AuthenticationResult.RefreshToken,
      expiresIn: authResult.AuthenticationResult.ExpiresIn,
      customer: {
        document,
        name,
        email,
      }
    })
  } catch (error) {
    if (error instanceof UsernameExistsException) {
      return formatResponse(409, {
        message: 'Document already exists'
      })

    }

    console.error('Register error:', error);
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
