import jwt
import logging
import json
import base64
import datetime


def lambda_handler(event, context):
  logger = logging.getLogger(__name__)
  logger.setLevel(level=logging.DEBUG)

  logger.debug(event)

  body = {}

  if login(event['headers']['Authorization']):
    encoded_jwt = jwt.encode({
      "created_at": datetime.datetime.utcnow().isoformat()
    }, "secret", algorithm="HS256")
    code = 200
    body = {
      'access_token': encoded_jwt,
      'token_type': "Bearer",
      'expires_in': 3600,
      'refresh_token': "FAKE_REFRESH",
      'scope': "get_protected"
    }
  else:
    code = 401
    body = {
      'error': 'unauthorized_client',
      'error_description': 'The client is not authorized to request an access token using this method.'
    }

  return {
    'statusCode': code,
    'body': json.dumps(body)
  }

def login(authorization):
  basic = authorization.split(' ')[1]
  [clientId, secret] = base64.b64decode(basic).decode('utf-8').split(':')
  return clientId == 'clientId' and secret == 'clientSecret'
