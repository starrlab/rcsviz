Tips for aDBS config: 
​

File location: `C:\AdaptiveDBS` 
​

Tips: 
* Be sure if you're running adaptive that LD0 is true and if you want LD1. AdaptiveState should be set to true to get the states. This is the sense in the sense config.
* AdaptiveState and AdaptiveTherapy should be true in stream to get the adaptive therapy charts to work. This is in the sense config.
* If you're only running LD0, then just set State0AmpInMilliamps-State2AmpInMilliamps in the adaptive config. Leave the rest at 25.5.
