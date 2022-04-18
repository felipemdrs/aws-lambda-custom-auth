import json
import logging

def lambda_handler(event, context):
  logger = logging.getLogger(__name__)
  logger.setLevel(level=logging.DEBUG)

  logger.debug(event)

  req_context = event['requestContext']
  custom = req_context['authorizer']['custom']

  logger.debug(req_context)

  return {
    'statusCode': 200,
    'body': json.dumps(f'Custom data from authorizer is {custom}')
  }
