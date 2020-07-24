# How to use elasticsearch-index-migrate
[Tools to use (elasticsearch-index-migrate)](https://github.com/kmiura-1002/elasticsearch-index-migrate)

# Setup

```bash
$ docker-compose up -d
```
Launch Elasticsearch7.7.0 and kibana7.7.0 for the sample environment.

# Description of Sample Data
We will create two indexes and add fields as sample data.
In this sample, there are two version-controllable code files, movie index and book-2020.01.01 index.

```
./sample
└── es7
    └── migration
        ├── config
        │   └── config.json
        └── indices
            ├── book
            │   └── 2020.01.01
            │       ├── v1.0.0__create_book_index.json
            │       └── v1.0.1__add_price_filed.json
            └── movie
                ├── v1.0.0__create_movie_index.json
                └── v1.0.1__add_year_filed.json

```
movie index contains migration codes in sample/es7/migration/indices/movie.
book-2020.01.01 index stores the code for migration in sample/es7/migration/indices/book/2020.01.01.  
If there is a - or _ in the index name, the directory storing the code for the migration changes.  
In this sample, that would be book-2020.01.01 index.  


In order for the tool to perform the migration, the location of the migration code and Elasticsearch's connection information can be found in sample/es7/migration/config/config.json.  
Here's what the configuration file looks like.  
```
{
  "elasticsearch": {
    "version": "7.7.0",
    "connect": { "host": "http://elasticsearch7x:9200" }
  },
  "migration": {
    "locations": ["./es7/migration"],
    "baselineVersion": "v1.0.0"
  }
}
```

The elasticsearch property contains the version and connection information.
The tool supports up to 6.x and <7.7.
You can connect to Elasticsearch by host, SSL, and CloudId.

- SSL
```
{
  "elasticsearch": {
    "version": "7.7.0",
    "connect": { 
      "host": "http://elasticsearch7x:9200",
      "sslCa": "..."
    }
  },
  "migration": {
    "locations": ["./es7/migration"],
    "baselineVersion": "v1.0.0"
  }
}
```

-  CloudId
  ```
  {
    "elasticsearch": {
      "version": "7.7.0",
      "connect": { 
        "cloudId": "...",
        "username": "..."
        "password": "..."
      }
    },
    "migration": {
      "locations": ["./es7/migration"],
      "baselineVersion": "v1.0.0"
    }
  }
  ```

In this sample, the json contains the connection information.
In a production environment, you don't want to put the connection information as it is in the file.
Therefore, you can set it as an environment variable and read it in.

To set the environment variables, set the following variables.
- ELASTICSEARCH_MIGRATION_LOCATIONS
- ELASTICSEARCH_MIGRATION_BASELINE_VERSION
- ELASTICSEARCH_VERSION
- ELASTICSEARCH_HOST
- ELASTICSEARCH_SSL
- ELASTICSEARCH_CLOUDID
- ELASTICSEARCH_USERNAME
- ELASTICSEARCH_PASSWORD

