import hmac
import json
import requests

# Encode the request parameters as a JSON string.
request_params = {}
request_params['clientId'] = 'smx-mobile-money'
request_params['requestId'] = '769b870d-5031-4121-98f1-b86b4985037b-45678765bb'
request_body = json.dumps(request_params).encode('UTF-8')
print(request_body)

# Sign the request body using HMAC-SHA256.
secret_key = 'AxdP2So5xigjTFOLFHR7d4oKJM3jvs11Zqn0lU3hyjZC'
digest = hmac.new(secret_key.encode('UTF-8'), msg=request_body, digestmod='SHA256')

# Render the Authorization header's value.
signature = digest.hexdigest()
print(signature)
authorization = 'Segovia signature={0}'.format(signature)

# Headers
headers = {
    'API-Version': '1.0',
    'Authorization': authorization,
    'Content-Type': 'application/json'
}
print(headers)
# Set up the URL and header lines.
url = 'https://payment-api.thesegovia.com/api/paymentproviders'
# url = 'https://payment-api.thesegovia.com/api/pay'
# url = 'https://payment-api.thesegovia.com/api/balance'
# url = 'https://payment-api.thesegovia.com/api/paymentproviders'
# url = 'https://payment-api.thesegovia.com/api/transactionstatus'

# Send the request and read the response from the payment gateway.
response = requests.post(url, data=request_body, headers=headers)
result = response.json()
print(result)

# Examine result and do whatever your application needs to do.