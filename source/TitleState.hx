package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = true; // Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.B, FlxKey.B]; // bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		#if MODS_ALLOWED
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		if (FileSystem.exists("modsList.txt")){
			var list:Array<String> = CoolUtil.listFromString(File.getContent("modsList.txt"));
			var foundTheTop = false;
			for (i in list){
				var dat = i.split("|");
				if (dat[1] == "1" && !foundTheTop){
					foundTheTop = true;
					Paths.currentModDirectory = dat[0];
				}

			}
		}
		#end

		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/gfDanceTitle.json";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "mods/images/gfDanceTitle.json";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "assets/images/gfDanceTitle.json";
		}
		//trace(path, FileSystem.exists(path));
		titleJSON = Json.parse(File.getContent(path));
		#else
		var path = Paths.getPreloadPath("images/gfDanceTitle.json");
		titleJSON = Json.parse(Assets.getText(path));
		#end

		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end
		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add(function(exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				startIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}

		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();




		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);


		var shouldUseBl:Bool = true;
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/logoBumpin.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/logoBumpin.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			shouldUseBl = false;
		}
		if (shouldUseBl) {
		//trace(path, FileSystem.exists(path));
		logoBl.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		#end

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		}

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);

		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/gfDanceTitle.png";
		// trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path))
		{
			path = "mods/images/gfDanceTitle.png";
			// trace(path, FileSystem.exists(path));
		}
		if (!FileSystem.exists(path))
		{
			path = "assets/images/gfDanceTitle.png";
			// trace(path, FileSystem.exists(path));
		}
		gfDance.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path), File.getContent(StringTools.replace(path, ".png", ".xml")));
		#else
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		#end
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		add(gfDance);
		gfDance.shader = swagShader.shader;
		if (shouldUseBl)
			add(logoBl);
		// logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		// trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path))
		{
			path = "mods/images/titleEnter.png";
		}
		// trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path))
		{
			path = "assets/images/titleEnter.png";
		}
		// trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path), File.getContent(StringTools.replace(path, ".png", ".xml")));
		#else
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		logo = new FlxSprite().loadGraphic(Paths.image('titlelogo'));
		logo.x = 100;
		logo.y = 50;
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		add(logo);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (!transitioning && skippedIntro)
		{
			if (pressedEnter) {
				if (titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				FlxTween.tween(logo, {x: -1500}, 3.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(gfDance, {x: -1500}, 3.7, {ease: FlxEase.expoInOut});
				FlxTween.tween(titleText, {y: 1500}, 3.7, {ease: FlxEase.expoInOut});

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			else if(easterEggEnabled)
			{
				var finalKey:FlxKey = FlxG.keys.firstJustPressed();
				if(finalKey != FlxKey.NONE) {
					lastKeysPressed.push(finalKey); //Convert int to FlxKey
					if(lastKeysPressed.length > easterEggKeyCombination.length)
					{
						lastKeysPressed.shift();
					}

					if(lastKeysPressed.length == easterEggKeyCombination.length)
					{
						var isDifferent:Bool = false;
						for (i in 0...lastKeysPressed.length) {
							if(lastKeysPressed[i] != easterEggKeyCombination[i]) {
								isDifferent = true;
								break;
							}
						}

						/*if(!isDifferent) {
							trace('Easter egg triggered!');
							FlxG.save.data.psykaEasterEgg = !FlxG.save.data.psykaEasterEgg;
							FlxG.sound.play(Paths.sound('secretSound'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							lastKeysPressed = [];
							closedState = true;
							transitioning = true;
						}*/
					}
				}
			}
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if (logo != null)
		{
			logo.scale.set(1.05, 1.05);
			FlxTween.tween(logo, {'scale.x': 0.95, 'scale.y': 0.95}, 0.1, {ease: FlxEase.bounceIn});
		}

		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(['ProjectFNF by'], 45);
				// credTextShit.visible = true;
				case 3:
					addMoreText('l1ttleO', 45);
					addMoreText('aflacc', 45);
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['Present a mod to'], -60);
				case 7:
					addMoreText('This game right below', -60);
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 14:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
