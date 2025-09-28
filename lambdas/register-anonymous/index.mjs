import {
  CognitoIdentityProviderClient,
  AdminCreateUserCommand,
  AdminSetUserPasswordCommand,
  AdminInitiateAuthCommand
} from '@aws-sdk/client-cognito-identity-provider'

const cognitoClient = new CognitoIdentityProviderClient({ region: 'us-east-1' })
const CLIENT_ID = process.env.CLIENT_ID
const USER_POOL_ID = process.env.USER_POOL_ID

export const handler = async (event) => {
  try {
    const sessionId = crypto.randomUUID()
    const anonymousUsername = `anonymous-${sessionId}`
    const anonymousPassword = `${sessionId}@Temp`

    // 1. Create anonymus user in Cognito
    const createUserCommand = new AdminCreateUserCommand({
      UserPoolId: USER_POOL_ID,
      Username: anonymousUsername,
      UserAttributes: [
        { Name: 'email', Value: `${anonymousUsername}@temp.local` },
        { Name: 'name', Value: 'Usuário Anônimo' },
        // { Name: 'custom:user_type', Value: 'anonymous' }
      ],
      TemporaryPassword: anonymousPassword,
      MessageAction: 'SUPPRESS' // Don't send confirmation email
    })

    await cognitoClient.send(createUserCommand)

    // 2. Set permanent password
    const setPasswordCommand = new AdminSetUserPasswordCommand({
      UserPoolId: USER_POOL_ID,
      Username: anonymousUsername,
      Password: anonymousPassword,
      Permanent: true
    })

    await cognitoClient.send(setPasswordCommand);

    // 3. Auth > Generate auth tokens
    const authCommand = new AdminInitiateAuthCommand({
      UserPoolId: USER_POOL_ID,
      ClientId: CLIENT_ID,
      AuthFlow: 'ADMIN_USER_PASSWORD_AUTH',
      AuthParameters: {
        USERNAME: anonymousUsername,
        PASSWORD: anonymousPassword
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
        type: 'anonymous',
        sessionId: sessionId
      }
    })
  } catch (error) {
    console.error('Register Anonymous error:', error);
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