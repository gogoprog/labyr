import gengine.*;
import gengine.math.*;
import gengine.components.*;
import gengine.graphics.*;

class Application
{
    private static var engine:Engine;

    public static function init()
    {
        trace("Labyr init");
        Gengine.setWindowSize(new IntVector2(1024, 768));
        Gengine.setWindowTitle("Labyr");
        //Gengine.setGuiFilename("gui/gui.html");
    }

    public static function start(_engine:Engine)
    {
        engine = _engine;
    }
}
