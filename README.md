# How to use elasticsearch-index-migrate
[Tools to use (elasticsearch-index-migrate)](https://github.com/kmiura-1002/elasticsearch-index-migrate)

# Setup

```bash
$ docker-compose up -d
```
or
```bash
$ sh sample.sh -setup
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


# How to
In order to use the tool, you need to install it or run it from Docker (in this sample, we'll do it in Docker).


- How to install
```
$ npm install -g elasticsearch-index-migrate
$ elasticsearch-index-migrate -h
```

- How to run it from Docker
```
$ docker pull kmiura1002/elasticsearch-index-migrate
$ docker run --rm  kmiura1002/elasticsearch-index-migrate -h
```

Next, you need to prepare the tool's configuration file. Configuration files are created in JSON.  
In this sample, a configuration file has been created in sample/es7/migration/config.  
Please refer to the previous section for [the configuration files](./README.md#Description of Sample Data)  

Next, we need to prepare a migration file.
The migration file should be created in the location you set in the configuration file migration.location.  


Create a directory named indices in the location specified in migration.location. 
Create a directory with the same name as the index name in the directory. 
The sample creates the movie and book directories, and if the index name contains _ or -, the directories will be separated. 
In our example, this is the book index, which we create with the directory `indices/book/2020.01.01`.  

Finally, create a migration file.
In our example, it has already been created.  

The contents of the migration file follow the following type.

```
{
  type: 'ADD_FIELD' | 'CREATE_INDEX' | 'DELETE_INDEX' | 'ALTER_SETTING';
  description: string;
  migrate_script: any;
}
```

The content of migrate_script varies depending on the type.  
For CREATE_INDEX, you can create an index. migrate_script can contain the contents of [the Request body of the Create index API](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html#indices-create-api-request-body).  
For ADD_FIELD, you can add an already existing index field. migrate_script can contain the contents of [the Request body of the Put mapping API](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html#put-mapping-api-request-body).  
For DELETE_INDEX, you can remove the index; migrate_script is not required.  
For ALTER_SETTING, you can manipulate the settings of an already existing index. migrate_script can contain the contents of the request body of [the Update index settings API](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html#update-index-settings-api-request-body).


# Creating an Implementation Plan
You can use the plan command to create an execution plan.
With this command, you can check if the execution plan for a series of changes is as expected.  

In the example, you can run it with either of the following.  

```
$ docker-compose run --rm elasticsearch-migrate plan -O es7/migration/config/config.json -i movie
```
```
$ sh sample.sh -plan movie 
```

When you run it, you will get an execution plan that looks like this.  

```
Version Description     Type         Installedon State   
v1.0.0  movie index     CREATE_INDEX             PENDING 
v1.0.1  add price filed ADD_FIELD                PENDING 
```

The version column shows the version of the migration file to be versioned.  

The Description column displays the description of the migration file.  

The Type column shows the type of the file.  

The Installedon column displays the date and time the migration was performed. 
If you have not yet performed the migration, nothing will be displayed.  

The State column shows the status of the migration.  
The status is displayed as one of the following.  
- PENDING: Pre-run, then migrated.
- BELOW_BASELINE: A version below the baseline is specified. No migration will be performed.
- IGNORED: Migration file with a version older than the latest version.
- MISSING_SUCCESS: Migration has already been performed successfully, but the migration file does not exist.
- MISSING_FAILED: Migration fails, but the migration file does not exist.
- SUCCESS: The migration has already been performed and is successful.
- FAILED: Migration failed. 
- FUTURE_SUCCESS: Migration was successful in the past and no file exists.
- FUTURE_FAILED: Migration has failed in the past and the file does not exist.

# Performing a Migration
Execute the migration file in the version of PENDING status with the plan command.  
In the example, you can run it with either of the following.  

```
docker-compose run --rm elasticsearch-migrate migrate -O es7/migration/config/config.json -i movie
```
```
$ sh sample.sh -migrate movie 
```
If you run the migration command and it finishes without error, you will see the following result
```
Start validate of migration data.
Start migration!
Successfully completed migration of v1.0.0__create_movie_index.json. (time: 105.60449999570847 ms)
Successfully completed migration of v1.0.1__add_year_filed.json. (time: 32.27530002593994 ms)
Finished migration! (time: 155.62639999389648 ms)
Migration completed. (count: 2)
```
The results show the execution time (ms) and total execution time for each migration file.
The migrate command has a `--showDiff` option.
If this option is present, it will show you the difference between the pre- and post-mapping after the migration
