# TB-InfectedZone

### Description
TB-InfectedZone is a script that allows you to have infection zones on the map (currently the whole city is infected), ideal for a survival server it was created for the Washingtonia 90's server (https: // discord. gg / UhUfZMN), it allows you to have an additional radiation resistance bar in esx_basicneeds, and depending on whether the player is wearing a mask or not, they will lose more or less resistance and stay in the area until they die. You can rework it entirely in your own way, I tried to be clearer in my comments, it will surely evolve later with animation additions, the best notifications, items to be more or less resistant.


### Prerequisites
  * [esx_status](https://github.com/ESX-Org/esx_billing)
  * [esx_basicneeds](https://github.com/esx-framework/esx_basicneeds)

### Installation
### With  Git
```
cd resources
git clone https://github.com/TheoBIET/TB-InfectedZone [esx]/TB-InfectedZone
```
- Add `ensure TB-InfectedZone` in your server.cfg
- Go to the configuration

### Manually
- Download https://github.com/TheoBIET/TB-InfectedZone.git
- Put `TB-InfectedZone` in your resources
- Add `ensure TB-InfectedZone` in your server.cfg
- Go to the configuration


### Configuration
1 - Add `TB-InfectedZone` in your resources

2 - In Event 'esx_basicneeds:resetStatus' add the following lines
`TriggerEvent('esx_status:set', 'bionaz', 200000)`


3 - In Event 'esx_basicneeds:healPlayer' add the following lines
`TriggerEvent('esx_status:set', 'bionaz', 1000000)`

4 - After Event 'esx_status:registerStatus' for the thirst add the following lines
```
TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1',
		function(status)
			return true
		end, function(status)
			status.remove(75)
		end
	)
```
4.2 - Add the following lines
```
TriggerEvent('esx_status:registerStatus', 'bionaz', 1000000, '#FF0016',
    function(status)
        return true
    end, function(status)
        status.remove(25)
    end
)
```
