import jwt
import logging
import datetime

def lambda_handler(event, context):
  logger = logging.getLogger(__name__)
  logger.setLevel(level=logging.DEBUG)

  logger.debug(event)

  token = event['authorizationToken'].split(' ')[1]

  try:
    data = jwt.decode(token, 'secret', "HS256")
    created_at = data['created_at']
    date = datetime.datetime.strptime(created_at, "%Y-%m-%dT%H:%M:%S.%f")

    if datetime.datetime.utcnow() < date + datetime.timedelta(0, 3600):
      return createReturn('unknown', 'ALLOW', event['methodArn'])
  except Exception as e:
    logging.error(e, exc_info=True)

  return createReturn('unknown', 'DENY', event['methodArn'])

def createReturn(principalId, effect, resource):
  return {
    'context': {
      'custom': 'Hello',
    },
    'principalId': principalId,
    'policyDocument': {
      'Version': '2012-10-17',
      'Statement': [{
        'Action': 'execute-api:Invoke',
        'Effect': effect,
        'Resource': resource
      }]
    }
  }
