setup:
  codecov_url: "${codecov_url}"
  enterprise_license: "${enterprise_license}"
  guest_access: ${guest_access}
  http:
    cookie_secret: "${cookie_secret}"
github:
  client_id: ${github_client_id}
  client_secret: ${github_client_secret}
  global_upload_token: ${github_global_upload_token}
github_enterprise:
  url: ${github_enterprise_url}
  api_url: ${github_enterprise_api_url}
  client_id: ${github_enterprise_client_id}
  client_secret: ${github_enterprise_client_secret}
  global_upload_token: ${github_enterprise_global_upload_token}
bitbucket:
  client_id: ${bitbucket_client_id}
  client_secret: ${bitbucket_client_secret}
  global_upload_token: ${bitbucket_global_upload_token}
bitbucket_server:
  url: ${bitbucket_server_url}
  client_id: ${bitbucket_server_client_id}
  global_upload_token: ${bitbucket_server_global_upload_token}
gitlab_enterprise:
  url: ${gitlab_enterprise_url}
  client_id: ${gitlab_enterprise_client_id}
  client_secret: ${gitlab_enterprise_client_secret}
  gitlab_enterprise_ssl_pem: ${gitlab_enterprise_ssl_pem}
  global_upload_token: ${gitlab_enterprise_global_upload_token}
services:
  ci_providers: ${ci_providers}
  database_url: postgres://${database_username}:${database_password}@${database_host}:${database_port}/${database_name}
  redis_url: redis://${redis_host}:${redis_port}
  minio: 
    hash_key: "ab164bf3f7d947f2a0681b215404873e" #do not edit
    access_key_id: ${minio_access_key}
    secret_access_key: ${minio_secret_key}
    host: ${minio_host}
    port: ${minio_port}
    client_uploads: ${minio_client_uploads}
