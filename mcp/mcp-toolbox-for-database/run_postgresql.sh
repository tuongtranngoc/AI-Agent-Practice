docker run --name postgres-emr \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_DB=postgres \
  -v $(pwd)/data/postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  -d postgres:16
