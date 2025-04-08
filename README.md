# Filebeat monitoring for log files

This repo contains the scripts to build and install the dockerize
version of Filebeat for log files.

Requirements:
 - Ubuntu or MacOS
 - Docker Compose V2
 - Elasticsearch


## Set up the index template in Elasticsearch
Set up the lifecycle policy. Go to the Dev Tools playground and run
the request to the Elasticsearch API:
```
PUT _ilm/policy/ILP-example
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": {
            "priority": 100
          },
          "rollover": {
            "max_primary_shard_size": "10gb",
            "max_age": "30d",
            "max_docs": 1000000
          }
        }
      },
      "warm": {
        "min_age": "15d",
        "actions": {
          "readonly": {},
          "set_priority": {
            "priority": 50
          },
          "forcemerge": {
            "max_num_segments": 1
          },
          "shrink": {
            "number_of_shards": 1
          },
          "migrate": {
            "enabled": true
          }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "set_priority": {
            "priority": 25
          }
        }
      },
      "delete": {
        "min_age": "45d",
        "actions": {
          "delete": {
            "delete_searchable_snapshot": true
          }
        }
      }
    }
  }
}
```

After the ILP, set up the Elasticsearch index template:
```
PUT _index_template/index-template-example
{
  "version": 1.0,
  "priority": 200,
  "index_patterns": ["example-*"],
  "data_stream": {},
  "template": {
    "settings": {
      "index": {
        "lifecycle": { "name": "ILP-example" },
        "refresh_interval": "10s",
        "number_of_shards": 2,
        "number_of_replicas":"0"
      }
    },
    "mappings": {
      "dynamic_templates": [
        {
          "strings_as_keywords": {
            "match_mapping_type": "string",
            "mapping": {
              "type": "keyword"
            }
          }
        } 
      ],
      "_data_stream_timestamp": { "enabled": true },
      "properties": {
        "@timestamp": { "type": "date" }
      }
    }
  }
}

```

## Set up the `.env` file
Copy the `.env.tmpl` file and modify your environment variables:

```bash
cp .env.tmpl .env
```

```bash
# Name of elasticsearch index
export ELASTIC_INDEX="index-example"
# Elasticsearch user
export ELASTIC_USER="username"
# Elasticsearch password
export ELASTIC_PASSWORD="password"
# Location of log folder
export LOGS_FOLDER="/var/log/example/"
# Name of log file
export LOGS_FILENAME="example.log"

```

## Deploy Elasticsearch

### 1. Build the Dockerize version of Elasticsearch
Run the script to build the Docker image of Elasticsearch:

**Note:** Once the image is built, there's no need to run the script again.

```bash
./build-elasticsearch.sh
```

### 2. Install Elasticsearch
Run the script to install the Docker image of Elasticsearch:

```bash
./install-elasticsearch.sh
```

### 3. Verify the status of the Elasticsearch container
Take a look at the logs of Elasticsearch service with:

```bash
docker logs elasticsearch
```
