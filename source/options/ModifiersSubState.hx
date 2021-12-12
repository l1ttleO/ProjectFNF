package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class ModifiersSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Modifiers';
		rpcTitle = 'Modifiers Menu'; // for Discord Rich Presence

		var option:Option = new Option('Dad Notes Do Damage', 'If checked, you will lose health when the opponent will hit notes',
			'dadNotesDoDamage', 'bool', false);
		addOption(option);

		var option:Option = new Option('Dad Notes Can Kill',
			'If checked, you can die when losing health from opponent notes',
			'downScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Damage from Dad Notes', 'Set how much health you lose from opponent notes', 'damageFromDadNotes', 'float', 1);
        option.displayFormat = option.getValue() < 10 ? '%v%' : "HARD MODE";
		option.scrollSpeed = 0.5;
		option.minValue = 0;
		option.maxValue = 10;
        addOption(option);

		var option:Option = new Option('Stuns Block Inputs', "If checked, missing will temporarily prevent you from hitting notes",
			'stunsBlockInputs', 'bool', false);
		addOption(option);

		super();
	}
}
