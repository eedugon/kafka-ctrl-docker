#!/bin/bash
set -e

# Common configuration
ZOOKEEPER_ENTRY_POINT="${ZOOKEEPER_ENTRY_POINT:-zookeeper:2181}"
KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST:-kafka:9092}"

use() {
    echo "kafka-ctl list-topics|remove-topic|create-topic [options]"
    echo "  list-topics : list all topics"
    echo "  delete-topic : delete a on more topic"
    echo "    options : NAME0 ... NAMEn"
    echo "      NAMEx : the name of topic to remove"
    echo "  describe-topic : give info of one or more topics"
    echo "    options : NAME0 ... NAMEn"
    echo "      NAMEx : the name of topic"
    echo "  create-topic : create one or more topics"
    echo "    options : [-s|-ns] [-r REPLICATION_FACTOR0 ] [-p PARTITIONS0] NAME0 ... [-s] [-r REPLICATION_FACTORn ] [-p PARTITIONSn] NAMEn"
    echo "      NAMEx : the name of the topic to create"
    echo "      -s : If active (present) only create topic if not exists (-ns inverse)"
    echo "      REPLICATION_FACTORx : replication factor used. Default 1"
    echo "      PARTITIONS0x : number of partitions. Default 1"
    echo ""
    echo "      -s REplication_ and PARTITIONS are remembered if you set they apply to next topics until you set it "
    echo "      Example create-topic -s -r 1 -p 2 topic1 topic2 is the same like"
    echo "      create-topic -s -r 1 -p 2 topic1 -s -r 1 -p 2 topic2"
    echo "  consume : consume and show data from a topic"
    echo "    options : NAME [--no-from-beginning] [--property PROP1=VALUE1 ... --property PROPn=VALUEn]"
    echo "      NAME : name of the topic to consume data"
    echo "      --no-from-beginning : if it is no present (default) data will "
    echo "        be consumed from the beginning of the topic. only new data in "
    echo "        other case"
    echo "      --property PROPx=VALUEx : set property PROPx with value VALUEx in consumer "
    echo "  produce : produce data (readed from file or stdin) and put in a topic"
    echo "    options : NAME [--file|-f filepath] [--property PROP1=VALUE1 ... --property PROPn=VALUEn]"
    echo "      NAME : name of the topic to consume data"
    echo "      --file|-f filepath file to use as data input, if it is not defined data will be read from stdin"
    echo "      --property PROPx=VALUEx : set property PROPx with value VALUEx in producer "

}

list_topics() {
  kafka-topics.sh --list --zookeeper "${ZOOKEEPER_ENTRY_POINT}"
}

delete_topics() {
  local name=""
  while [ -n "$1" ]
  do
    name="$1"
    kafka-topics.sh --delete --topic "$name" --zookeeper "${ZOOKEEPER_ENTRY_POINT}"
    shift
  done
}

describe_topic() {
  local name=""
  while [ -n "$1" ]
  do
    name="$1"
    kafka-topics.sh --describe --topic "$name" --zookeeper "${ZOOKEEPER_ENTRY_POINT}"
    shift
  done
}

create_topics() {
  local safe="no"
  local repl_fct=1
  local partitions=1
  local name=""
  while [ -n "$1" ]
  do
    case $1 in
      -r)
        shift 1
        repl_fct=$1
        ;;
      -p)
        shift 1
        partitions=$1
        ;;
      -s)
        safe="yes"
        ;;
      -ns)
        safe="no"
        ;;
      *)
        name="$1"
        if [ "$safe" == "yes" ]
        then
          if kafka-topics.sh --describe --topic "$name" --zookeeper "${ZOOKEEPER_ENTRY_POINT}" 2>&1 | fgrep "$name" > /dev/null
          then
            echo "Topic $name exists. Ignoring"
          else
             kafka-topics.sh --create --topic "$name" --replication-factor "$repl_fct" --partitions "${partitions}" --zookeeper "${ZOOKEEPER_ENTRY_POINT}"
          fi
        else
          kafka-topics.sh --create --topic "$name" --replication-factor "$repl_fct" --partitions "${partitions}" --zookeeper "${ZOOKEEPER_ENTRY_POINT}"
        fi
        ;;
    esac
    shift
  done
}

consume() {
  local from_beginning="--from-beginning"
  local name="$1"
  shift
  local otherOptions=()
  while [ ! -z "$1" ]
  do
    case $1 in
      --no-from-beginning)
        from_beginning=""
        ;;
      *)
        otherOptions+=" $1"
        ;;
    esac
    shift
  done

  kafka-console-consumer.sh ${otherOptions[@]} --topic "$name" "$from_beginning" --bootstrap-server "${KAFKA_BROKER_LIST}"
}

produce() {
  local name="$1"
  shift
  ## Empty file is standar input
  local inputFile=""
  case "$1" in
    --file|-f)
        if [ -z "$2" ]
        then
          echo "produce with --file|-f option without value"
          use
          exit 1
        fi
        inputFile="$2"
        shift 2
      ;;
  esac
  cat $inputFile | kafka-console-producer.sh $@ --topic "$name" --broker-list "${KAFKA_BROKER_LIST}"
}

case $1 in
  list-topics)
    list_topics
    ;;
  create-topic)
    shift
    create_topics $@
    ;;
  delete-topic)
    shift
    delete_topics $@
    ;;
  describe-topic)
    shift
    describe_topic $@
    ;;
  consume)
    shift
    consume $@
    ;;
  produce)
    shift
    produce $@
    ;;
  *)
    use
    exit 1
    ;;
esac
