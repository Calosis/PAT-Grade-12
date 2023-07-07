# PAT-Grade-12
PAT for Grade 12 2023 (South Africa) - https://wcedeportal.co.za/eresource/227406

### WIP Project. As of 5/07/2023 this project is still incomplete. Feel free to use this as a learning resource and assistance in your PAT.

**Contains**:
* Login + Register forms using database and SQL.
* 2FA System utilizing Google Authenticator with QR code building.
* [WIP]

### Error on compile fix:
```[MSBuild Error] The "GetItCmd" task failed unexpectedly.
System.NullReferenceException: Object reference not set to an instance of an object.
   at Borland.Build.Tasks.Common.CommandLineTask.Execute()
   at Borland.Build.Tasks.Shared.GetItCmd.Execute()
   at Microsoft.Build.BuildEngine.TaskEngine.ExecuteInstantiatedTask(EngineProxy engineProxy, ItemBucket bucket, TaskExecutionMode howToExecuteTask, ITask task, Boolean& taskResult)```

_______________________________________
 
[*] Set the BDSHost environment variable to true in the Delphi IDE settings:

    	Go to Tools > Options.
    	Go to Environment Options > Environment Variables.
    	Under User overrides, click New.
    	Variable name: BDSHost, Variable value: true.
