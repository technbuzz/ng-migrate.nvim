your-plugin-repo/
└── lua/
    └── ng-migrate/
        ├── init.lua   <-- Main UI/Telescope logic
        └── utils.lua  <-- The "Engine room" (read_json, etc.)
        
To list all the migration schematics
```
❯ ng g @angular/core:output-migration --help 
```

All other generator schematics
```
❯ ng g @angular/core --help
```
