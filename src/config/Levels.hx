package config;

import components.Tile;

public class Levels
{
    public static var data = [
    {
        time: 60.0,
        powerup: 0.3,
        probabilities:{
            Powerup.ABOMB: 0.5,
            Powerup.HBOMB: 0.5
        },
        targets: {
            Powerup.ABOMB: 1
        }
    }
    ]
}
