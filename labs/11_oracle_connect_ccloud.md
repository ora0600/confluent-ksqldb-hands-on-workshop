# Connect Oracle DB 12.2 with fully-managed Connector (ready with Confluent Cloud)
We prepared an a running DB 12.2 from Oracle with deployed data model including data.
The task is know to create an fully-managed Connector and load data from Oracle DB.

We will use the fully-managed Oracle Source Connector in Confluent Cloud.
You can setup the connector with GUI or `ccloud cli`.
In this case we will create connector with the GUI.
The cli would looks like this: 
```bash
ccloud connector create --cluster YOUR-cluster-id --config oracle.properties
```

toDo

End lab11

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)

