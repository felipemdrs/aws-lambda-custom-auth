import logging

def lambda_handler(event, context):
  logger = logging.getLogger(__name__)
  logger.setLevel(level=logging.DEBUG)

  logger.debug(event)

  token = event['authorizationToken']

  return createReturn('unknown', 'ALLOW', event['methodArn'])


def createReturn(principalId, effect, resource):
  return {
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
