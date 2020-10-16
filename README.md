# TB-InfectedZone

### Description
TB-InfectedZone est un script qui permet d'avoir des zones d'infection sur la carte (actuellement toute la ville est infectée), idéal pour un serveur de survie il a été créé pour le serveur Washingtonia 90's (https://discord.gg/UhUfZMN), il vous permet d'avoir une barre de résistance aux radiations supplémentaire dans esx_basicneeds, et selon si le joueur porte un masque ou non, il perdra plus ou moins de resistance en restant dans la zone jusqu'à mourrir. Vous pouvez le retravailler entièrement à votre manière, j'ai essayé d'être le plus clair dans mes commentaires, celui-ci évoluera sûrement par la suite avec des ajouts d'animation, de meilleures notifications, des items afin d'être plus ou moins résistant.


### Pré-requis
  * [esx_status](https://github.com/ESX-Org/esx_billing)
  * [esx_basicneeds](https://github.com/esx-framework/esx_basicneeds)

### Installation
### En utilisant Git
```
cd resources
git clone https://github.com/TheoBIET/TB-InfectedZone [esx]/TB-InfectedZone
```
- Ajoutez `ensure TB-InfectedZone` dans votre server.cfg
- Passez à la Configuration

### Manuellement
- Téléchargez https://github.com/TheoBIET/TB-InfectedZone.git
- Mettez `TB-InfectedZone` dans vos ressources
- Ajoutez `ensure TB-InfectedZone` dans votre server.cfg
- Passez à la Configuration


### Configuration
1 - Ajoutez TB-InfectedZone dans vos resources

2 - Dans l'Event 'esx_basicneeds:resetStatus' ajoutez la ligne (ci-dessous)
`TriggerEvent('esx_status:set', 'bionaz', 200000)`


3 - Dans l'Event 'esx_basicneeds:healPlayer' ajoutez la ligne (ci-dessous)
`TriggerEvent('esx_status:set', 'bionaz', 1000000)`

4 - Après l'Event 'esx_status:registerStatus' pour la soif`(ci-dessous)
```
TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1',
		function(status)
			return true
		end, function(status)
			status.remove(75)
		end
	)
```
4.2 - Ajoutez (ci-dessous)
```
TriggerEvent('esx_status:registerStatus', 'bionaz', 1000000, '#FF0016',
    function(status)
        return true
    end, function(status)
        status.remove(25)
    end
)
```
