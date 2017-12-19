import components.Tile;

typedef Level =
{
    var time:Float;
    var targets:Map<Powerup, Int>;
    var probabilities:Map<Powerup, Float>;
    var powerup:Float;
}
