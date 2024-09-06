sudo docker run --rm --pull always -p 7000:8000 -v ~/surrealdb_data:/surrealdb_data surrealdb/surrealdb:latest start --log trace -A --auth --user root --pass root file:surrealdb_data/test.db
