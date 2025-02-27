class Image
	const Texture atlas = {"atlas-v1.png", size:{4096,4096}}
	global const Image Background = {"media/Background.png", atlas, {2604,1924}, [{x1:2,y1:2,x2:2602,y2:1922,w:2600,h:1920}]}
	global const Image TopPipe = {"media/TopPipe.png", atlas, {212,1084}, [{x1:2606,y1:2,x2:2814,y2:1082,w:208,h:1080}]}
	global const Image BottomPipe = {"media/BottomPipe.png", atlas, {212,972}, [{x1:2818,y1:2,x2:3026,y2:970,w:208,h:968}]}
	global const Image VideoScreen = {"lib/core/play/media/VideoScreen0.png", atlas, {444,444}, [{x1:2,y1:1926,x2:442,y2:2256,w:440,h:330},{x1:2,y1:2260,x2:442,y2:2700,w:440,h:440}]}
	global const Image LargeButton = {"lib/core/play/media/LargeButton.png", atlas, {427,65}, [{x1:446,y1:1926,x2:869,y2:1987,w:423,h:61}]}
	global const Image LargeButtonAccent = {"lib/core/play/media/LargeButtonAccent1.png", atlas, {427,65}, [{x1:1300,y1:1926,x2:1722,y2:1987,w:422,h:61},{x1:873,y1:1926,x2:1296,y2:1987,w:423,h:61}]}
	global const Image Button = {"lib/core/play/media/Button.png", atlas, {305,65}, [{x1:1726,y1:1926,x2:2027,y2:1987,w:301,h:61}]}
	global const Image ButtonAccent = {"lib/core/play/media/ButtonAccent1.png", atlas, {305,65}, [{x1:2336,y1:1926,x2:2636,y2:1987,w:300,h:61},{x1:2031,y1:1926,x2:2332,y2:1987,w:301,h:61}]}
	global const Image Nuke = {"lib/core/play/media/Nuke0.png", atlas, {260,260}, [{x1:446,y1:1991,x2:702,y2:2247,w:256,h:256},{x1:706,y1:1991,x2:962,y2:2247,w:256,h:256},{x1:1226,y1:2260,x2:1482,y2:2516,w:256,h:256},{x1:1746,y1:2260,x2:2002,y2:2516,w:256,h:256},{x1:2006,y1:2260,x2:2262,y2:2516,w:256,h:256},{x1:2266,y1:2260,x2:2522,y2:2516,w:256,h:256},{x1:2526,y1:2260,x2:2782,y2:2516,w:256,h:256},{x1:2,y1:2704,x2:258,y2:2960,w:256,h:256},{x1:262,y1:2704,x2:518,y2:2960,w:256,h:256},{x1:522,y1:2704,x2:778,y2:2960,w:256,h:256},{x1:966,y1:1991,x2:1222,y2:2247,w:256,h:256},{x1:1226,y1:1991,x2:1482,y2:2247,w:256,h:256},{x1:1486,y1:1991,x2:1742,y2:2247,w:256,h:256},{x1:1746,y1:1991,x2:2002,y2:2247,w:256,h:256},{x1:2006,y1:1991,x2:2262,y2:2247,w:256,h:256},{x1:2266,y1:1991,x2:2522,y2:2247,w:256,h:256},{x1:2526,y1:1991,x2:2782,y2:2247,w:256,h:256},{x1:446,y1:2260,x2:702,y2:2516,w:256,h:256},{x1:706,y1:2260,x2:962,y2:2516,w:256,h:256},{x1:966,y1:2260,x2:1222,y2:2516,w:256,h:256},{x1:1486,y1:2260,x2:1742,y2:2516,w:256,h:256}]}
	global const Image SmallButton = {"lib/core/play/media/SmallButton.png", atlas, {172,45}, [{x1:2818,y1:974,x2:2986,y2:1015,w:168,h:41}]}
	global const Image SmallButtonAccent = {"lib/core/play/media/SmallButtonAccent1.png", atlas, {172,45}, [{x1:2818,y1:1064,x2:2985,y2:1105,w:167,h:41},{x1:2818,y1:1019,x2:2986,y2:1060,w:168,h:41}]}
	global const Image Bird = {"media/Bird01.png", atlas, {148,116}, [{x1:2818,y1:1109,x2:2962,y2:1221,w:144,h:112},{x1:2818,y1:1225,x2:2962,y2:1337,w:144,h:112},{x1:2818,y1:1341,x2:2962,y2:1453,w:144,h:112}]}
	global const Image finger = {"lib/core/play/media/finger0.png", atlas, {57,80}, [{x1:2966,y1:1109,x2:3019,y2:1185,w:53,h:76},{x1:2966,y1:1225,x2:3019,y2:1301,w:53,h:76}]}
	global const Image Next = {"lib/core/play/media/Next.png", atlas, {68,68}, [{x1:2818,y1:1457,x2:2882,y2:1521,w:64,h:64}]}
	global const Image ThumbsUp = {"lib/core/play/media/ThumbsUp.png", atlas, {68,68}, [{x1:2886,y1:1457,x2:2950,y2:1521,w:64,h:64}]}
	global const Image Spark = {"lib/core/play/media/Spark0.png", atlas, {62,62}, [{x1:2966,y1:1341,x2:3024,y2:1399,w:58,h:58},{x1:2922,y1:1629,x2:2970,y2:1677,w:48,h:48},{x1:2870,y1:1681,x2:2908,y2:1719,w:38,h:38}]}
	global const Image Back = {"lib/core/play/media/Back.png", atlas, {52,52}, [{x1:2966,y1:1403,x2:3014,y2:1451,w:48,h:48}]}
	global const Image cameraIcon = {"lib/core/play/media/cameraIcon.png", atlas, {52,52}, [{x1:2954,y1:1457,x2:3002,y2:1505,w:48,h:48}]}
	global const Image Checkbox = {"lib/core/play/media/Checkbox0.png", atlas, {52,52}, [{x1:2818,y1:1525,x2:2866,y2:1573,w:48,h:48},{x1:2870,y1:1525,x2:2918,y2:1573,w:48,h:48}]}
	global const Image Help = {"lib/core/play/media/Help0.png", atlas, {52,52}, [{x1:2922,y1:1525,x2:2970,y2:1573,w:48,h:48},{x1:2974,y1:1525,x2:3022,y2:1573,w:48,h:48}]}
	global const Image Menu = {"lib/core/play/media/Menu.png", atlas, {52,52}, [{x1:2818,y1:1577,x2:2866,y2:1625,w:48,h:48}]}
	global const Image microphoneIcon = {"lib/core/play/media/microphoneIcon.png", atlas, {52,52}, [{x1:2870,y1:1577,x2:2918,y2:1625,w:48,h:48}]}
	global const Image New = {"lib/core/play/media/New.png", atlas, {52,52}, [{x1:2922,y1:1577,x2:2970,y2:1625,w:48,h:48}]}
	global const Image Quit = {"lib/core/play/media/Quit.png", atlas, {52,52}, [{x1:2974,y1:1577,x2:3022,y2:1625,w:48,h:48}]}
	global const Image Save = {"lib/core/play/media/Save.png", atlas, {52,52}, [{x1:2818,y1:1629,x2:2866,y2:1677,w:48,h:48}]}
	global const Image settingsIcon = {"lib/core/play/media/settingsIcon.png", atlas, {52,52}, [{x1:2870,y1:1629,x2:2918,y2:1677,w:48,h:48}]}
	global const Image speakerIcon = {"lib/core/play/media/speakerIcon.png", atlas, {52,52}, [{x1:2974,y1:1629,x2:3022,y2:1677,w:48,h:48}]}
	global const Image starParticle = {"lib/core/play/media/starParticle2.png", atlas, {52,48}, [{x1:2912,y1:1681,x2:2938,y2:1705,w:26,h:24},{x1:2990,y1:999,x2:3000,y2:1009,w:10,h:10},{x1:2818,y1:1681,x2:2866,y2:1725,w:48,h:44}]}
	global const Image Tutorial = {"lib/core/play/media/Tutorial.png", atlas, {52,52}, [{x1:2818,y1:1729,x2:2866,y2:1777,w:48,h:48}]}
	global const Image[] Flag = [{"lib/core/play/media/Flag-Language1-State0.png", atlas, {37,25}, [{x1:2989,y1:1064,x2:3021,y2:1085,w:32,h:21},{x1:2966,y1:1189,x2:2998,y2:1210,w:32,h:21}]},{"lib/core/play/media/Flag-Language1-State0.png", atlas, {37,25}, [{x1:2990,y1:974,x2:3023,y2:995,w:33,h:21},{x1:2990,y1:1019,x2:3023,y2:1040,w:33,h:21}]}]
	global const Image ResizeHandle = {"lib/core/play/media/ResizeHandle.png", atlas, {36,36}, [{x1:2966,y1:1305,x2:2998,y2:1337,w:32,h:32}]}

class Font
	global const Font ByTheWay = {"ByTheWay", "ByTheWay.woff2"}
	global const Font OpenSans = {"OpenSans", "OpenSans.woff2"}
	global const Font ShadowedSerif = {"ShadowedSerif", "ShadowedSerif.woff2"}

transient unit Platform
	js void openMedia: void() callback
		Promise.all([$Image.atlas.open(),Font.ByTheWay.open(),Font.OpenSans.open(),Font.ShadowedSerif.open()]).then(() => callback())
	cpp void openMedia
		Image::atlas->open();
		Font::ByTheWay->open();
		Font::OpenSans->open();
		Font::ShadowedSerif->open();
		Sound::LobbyImpact->open();
