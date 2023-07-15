# PAT-Grade-12
PAT for Grade 12 2023 (South Africa) - https://wcedeportal.co.za/eresource/227406
(Built using Delphi 11)

~### WIP Project. As of 5/07/2023, this project is still incomplete. Feel free to use this as a learning resource and assistance in your PAT.~

**Contains**:
* Login + Register forms using database and SQL.
* 2FA system utilizing Google Authenticator with QR code building. (Base32 Impl included.)
* Object Class (constructor, get, set).
* Functions class with helpful methods. (Centre Window, SQL, Round Component, etc).
* Advanced use of objects, arrays, and dynamic components.
* All database manipulation (SQL + Code) needed as per the marking aid.
* All input from the user is validated.
* Side panel functionality (show/hide).
* GUI design follows all that is needed as per the marking aid.
* TextFile usage for comments.
* All code is commented and the layout is structured as per the marking aid.
* Database utilizing a one-to-many relation and a linking table.
_____________________________________________________

2023's PAT topic was a program that would "save the environment"/"help the environment" and preserve the natural wonders of the Earth. This program replicates the idea of https://change.org, a website where users can create, share, comment, and show their support for different issues around the world.  



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
