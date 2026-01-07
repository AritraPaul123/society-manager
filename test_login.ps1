$body = '{"username":"guard@society.com","password":"1234","platform":"mobile"}'
Invoke-RestMethod -Uri "http://localhost:5001/api/v1/auth/authenticate" -Method Post -Body $body -ContentType "application/json"
