class CfgPatches
{
	class PHEN_Cybernetics
	{
		units[]=
		{
			"PHEN_Cybernetics_ModuleAddTerminalActions"
		};
		weapons[]=
		{
			"PHEN_CS_LowLightOptics_MkI",
			"PHEN_CS_LowLightOptics_MkII",
			"PHEN_CS_LowLightOptics_MkIII",
			"PHEN_CS_LowLightOptics_MkIV"
		};
		requiredVersion="0.0.1";
		version="0.0.5";
		versionStr="0.0.5";
		versionAr[]={0,0,5};
		requiredAddons[]=
		{
			"A3_Weapons_F",
			"cba_main",
			"zen_custom_modules"
		};
		author="Phenosi / 'The VII Legion: Imperial Fists' Developers";
	};
};
class CfgSettings
{
	class CBA
	{
		class Versioning
		{
			class PHEN_Cybernetics
			{
				main_addon="PHEN_Cybernetics";
				class Dependencies
				{
					CBA[]=
					{
						"cba_main",
						{3,5,0},
						"true"
					};
				};
			};
		};
	};
};
class CyberneticsSystemDialog
{
	idd=2312769;
	class ControlsBackground
	{
		class BG
		{
			type=0;
			idc=0;
			x="safeZoneX + safeZoneW * 0";
			y="safeZoneY + safeZoneH * 0";
			w="safeZoneW * 1";
			h="safeZoneH * 1";
			style=0;
			text="";
			onLoad="_this spawn { params ['_displayOrControl', ['_config', configNull]]; playSoundUI ['PHEN_CS_UI_HUD_Notification', 1]; };";
			onUnload="_this spawn { params ['_display', '_exitCode']; playSoundUI ['PHEN_CS_UI_Micro_App_Close', 1]; };";
			colorBackground[]={0,0,0,0.50590003};
			colorText[]={0,0,0,0.34999999};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class BG_Image
		{
			type=0;
			idc=1;
			x="safeZoneX + safeZoneW * 0.025";
			y="safeZoneY + safeZoneH * 0.075";
			w="safeZoneW * 0.95";
			h="safeZoneH * 0.85";
			style="2048+48";
			onLoad="_this spawn { params ['_displayOrControl', ['_config', configNull]]; _displayOrControl ctrlSetText PHEN_CS_HUD_Texture; [] call PHEN_CS_fnc_LoadList; };";
			text="PHEN_Cybernetics\Data\HUD_0_CA.paa";
			colorBackground[]={1,1,1,1};
			colorText[]={1,1,1,1};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class PlayerName
		{
			idc=2;
			x="safeZoneX + safeZoneW * 0.45104167";
			y="safeZoneY + safeZoneH * 0.10185186";
			w="safeZoneW * 0.1";
			h="safeZoneH * 0.04";
			style=2;
			text="USER#: PLAYER NAME";
			colorBackground[]={0.9059,0.80779999,0.46270001,0};
			colorText[]={1,1,1,1};
			font="PuristaLight";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			onLoad="_ctrl = _this#0; _ctrl ctrlSetText (name player);";
			shadow=1;
		};
		class StressBarLabel
		{
			type=0;
			idc=9900;
			x="safeZoneX + safeZoneW * 0.3";
			y="safeZoneY + safeZoneH * 0.914";
			w="safeZoneW * 0.4";
			h="safeZoneH * 0.013";
			style=2;
			text="NEURAL STRESS";
			colorBackground[]={0,0,0,0};
			colorText[]={0.80000001,0.80000001,0.80000001,0.80000001};
			font="PuristaLight";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			shadow=1;
		};
		class StressBarBG
		{
			type=8;
			idc=9901;
			x="safeZoneX + safeZoneW * 0.3";
			y="safeZoneY + safeZoneH * 0.930";
			w="safeZoneW * 0.4";
			h="safeZoneH * 0.013";
			style=0;
			text="";
			texture="";
			colorBackground[]={0.1,0.1,0.1,0.69999999};
			colorBar[]={0.15000001,0.15000001,0.15000001,0.69999999};
			colorFrame[]={0,0,0,0};
			colorText[]={0.15000001,0.15000001,0.15000001,0.69999999};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			onLoad="_ctrl = _this # 0; _ctrl progressSetPosition 1;";
		};
		class StressBarFill
		{
			type=8;
			idc=9902;
			x="safeZoneX + safeZoneW * 0.3";
			y="safeZoneY + safeZoneH * 0.930";
			w="safeZoneW * 0.4";
			h="safeZoneH * 0.013";
			style=0;
			text="";
			texture="";
			colorBackground[]={0,0,0,0};
			colorBar[]={0.95300001,0.898,0,1};
			colorFrame[]={0,0,0,0};
			colorText[]={0.95300001,0.898,0,1};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			onLoad="_ctrl = _this # 0; _ctrl call PHEN_CS_fnc_StressBarInit_Self;";
		};
	};
	class Controls
	{
		class PHEN_CS_SlotBase
		{
			idc=-1;
			x="safeZoneX + safeZoneW * 1";
			y="safeZoneY + safeZoneH * 1";
			w="safeZoneW * 0.0453125";
			h="safeZoneH * 0.07685186";
			style="2048+48";
			text="";
			fixedWidth=0;
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			moving="false";
			onLoad="_ctrl = _this#0; _ctrl ctrlSetTooltipMaxWidth (SafeZoneW / 2);";
			onMouseEnter="_ctrl = _this#0; _ctrl ctrlSetTooltipMaxWidth (SafeZoneW / 2);";
			shadow=1;
			tooltip="Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
			tooltipColorBox[]={0.77249998,0,0.2353,1};
			tooltipColorShade[]={0.40000001,0.40000001,0.40000001,1};
			tooltipColorText[]={0.33329999,0.91759998,0.83139998,1};
			type=1;
			colorBackground[]={1,1,1,0};
			colorBackgroundActive[]={1,1,1,0};
			colorBackgroundDisabled[]={1,1,1,0};
			colorBorder[]={0,0,0,0};
			colorDisabled[]={1,1,1,0};
			colorFocused[]={1,1,1,0};
			colorShadow[]={0,0,0,0};
			colorText[]={1,1,1,1};
			borderSize=0;
			offsetPressedX=0;
			offsetPressedY=0;
			offsetX=0;
			offsetY=0;
			soundClick[]=
			{
				"PHEN_Cybernetics\sounds\UITouchscreenSubmitButton",
				0.090000004,
				1
			};
			soundEnter[]=
			{
				"PHEN_Cybernetics\sounds\UITouchScreenGlassButton.wav",
				0.090000004,
				1
			};
			soundEscape[]={};
			soundPush[]=
			{
				"PHEN_Cybernetics\sounds\UITouchscreenSweep",
				0.090000004,
				1
			};
			onMouseButtonClick="";
			onMouseExit="";
			onSetFocus="";
		};
		class FC_0: PHEN_CS_SlotBase
		{
			idc=100;
			x="safeZoneX + safeZoneW * 0.22708334";
			y="safeZoneY + safeZoneH * 0.15925926";
		};
		class FC_1: PHEN_CS_SlotBase
		{
			idc=101;
			x="safeZoneX + safeZoneW * 0.28072917";
			y="safeZoneY + safeZoneH * 0.15925926";
		};
		class FC_2: PHEN_CS_SlotBase
		{
			idc=102;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.15925926";
		};
		class OS_0: PHEN_CS_SlotBase
		{
			idc=200;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.24722223";
		};
		class CS_0: PHEN_CS_SlotBase
		{
			idc=300;
			x="safeZoneX + safeZoneW * 0.22708334";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class CS_1: PHEN_CS_SlotBase
		{
			idc=301;
			x="safeZoneX + safeZoneW * 0.28125";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class CS_2: PHEN_CS_SlotBase
		{
			idc=302;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class IS_0: PHEN_CS_SlotBase
		{
			idc=400;
			x="safeZoneX + safeZoneW * 0.28072917";
			y="safeZoneY + safeZoneH * 0.52037038";
		};
		class IS_1: PHEN_CS_SlotBase
		{
			idc=401;
			x="safeZoneX + safeZoneW * 0.33697917";
			y="safeZoneY + safeZoneH * 0.52037038";
		};
		class NS_0: PHEN_CS_SlotBase
		{
			idc=500;
			x="safeZoneX + safeZoneW * 0.28177084";
			y="safeZoneY + safeZoneH * 0.61296297";
		};
		class NS_1: PHEN_CS_SlotBase
		{
			idc=501;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.61296297";
		};
		class ITS_0: PHEN_CS_SlotBase
		{
			idc=600;
			x="safeZoneX + safeZoneW * 0.2265625";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
		class ITS_1: PHEN_CS_SlotBase
		{
			idc=601;
			x="safeZoneX + safeZoneW * 0.28072917";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
		class ITS_2: PHEN_CS_SlotBase
		{
			idc=602;
			x="safeZoneX + safeZoneW * 0.33333334";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
		class OPS_0: PHEN_CS_SlotBase
		{
			idc=700;
			x="safeZoneX + safeZoneW * 0.61666667";
			y="safeZoneY + safeZoneH * 0.24722223";
		};
		class SK_0: PHEN_CS_SlotBase
		{
			idc=800;
			x="safeZoneX + safeZoneW * 0.61614584";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class SK_1: PHEN_CS_SlotBase
		{
			idc=801;
			x="safeZoneX + safeZoneW * 0.67083334";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class H_0: PHEN_CS_SlotBase
		{
			idc=900;
			x="safeZoneX + safeZoneW * 0.61666667";
			y="safeZoneY + safeZoneH * 0.52037038";
		};
		class A_0: PHEN_CS_SlotBase
		{
			idc=1000;
			x="safeZoneX + safeZoneW * 0.6171875";
			y="safeZoneY + safeZoneH * 0.61296297";
		};
		class L_0: PHEN_CS_SlotBase
		{
			idc=1100;
			x="safeZoneX + safeZoneW * 0.6171875";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
	};
};
class CyberneticsSystemDialog_other
{
	idd=2312770;
	class ControlsBackground
	{
		class BG
		{
			type=0;
			idc=0;
			x="safeZoneX + safeZoneW * 0";
			y="safeZoneY + safeZoneH * 0";
			w="safeZoneW * 1";
			h="safeZoneH * 1";
			style=0;
			text="";
			onLoad="_this spawn { params ['_displayOrControl', ['_config', configNull]]; playSoundUI ['PHEN_CS_UI_HUD_Notification', 1]; };";
			onUnload="_this spawn { params ['_display', '_exitCode']; playSoundUI ['PHEN_CS_UI_Micro_App_Close', 1]; };";
			colorBackground[]={0,0,0,0.50590003};
			colorText[]={0,0,0,0.34999999};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class BG_Image
		{
			type=0;
			idc=1;
			x="safeZoneX + safeZoneW * 0.025";
			y="safeZoneY + safeZoneH * 0.075";
			w="safeZoneW * 0.95";
			h="safeZoneH * 0.85";
			style="2048+48";
			onLoad="_this spawn { params ['_displayOrControl', ['_config', configNull]]; _displayOrControl ctrlSetText PHEN_CS_HUD_Texture; [uiNamespace getVariable ['PHEN_CS_OtherUnit', objNull]] call PHEN_CS_fnc_LoadList; };";
			text="PHEN_Cybernetics\Data\HUD_0_CA.paa";
			colorBackground[]={1,1,1,1};
			colorText[]={1,1,1,1};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class PlayerName
		{
			idc=2;
			x="safeZoneX + safeZoneW * 0.45104167";
			y="safeZoneY + safeZoneH * 0.10185186";
			w="safeZoneW * 0.1";
			h="safeZoneH * 0.04";
			style=2;
			text="USER#: PLAYER NAME";
			colorBackground[]={0.9059,0.80779999,0.46270001,0};
			colorText[]={1,1,1,1};
			font="PuristaLight";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			onLoad="_ctrl = _this#0; _ctrl ctrlSetText '### USERNAME ###';";
			shadow=1;
		};
		class StressBarLabel
		{
			type=0;
			idc=9900;
			x="safeZoneX + safeZoneW * 0.3";
			y="safeZoneY + safeZoneH * 0.914";
			w="safeZoneW * 0.4";
			h="safeZoneH * 0.013";
			style=2;
			text="NEURAL STRESS";
			colorBackground[]={0,0,0,0};
			colorText[]={0.80000001,0.80000001,0.80000001,0.80000001};
			font="PuristaLight";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			shadow=1;
		};
		class StressBarBG
		{
			type=8;
			idc=9901;
			x="safeZoneX + safeZoneW * 0.3";
			y="safeZoneY + safeZoneH * 0.930";
			w="safeZoneW * 0.4";
			h="safeZoneH * 0.013";
			style=0;
			text="";
			texture="";
			colorBackground[]={0.1,0.1,0.1,0.69999999};
			colorBar[]={0.15000001,0.15000001,0.15000001,0.69999999};
			colorFrame[]={0,0,0,0};
			colorText[]={0.15000001,0.15000001,0.15000001,0.69999999};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			onLoad="_ctrl = _this # 0; _ctrl progressSetPosition 1;";
		};
		class StressBarFill
		{
			type=8;
			idc=9902;
			x="safeZoneX + safeZoneW * 0.3";
			y="safeZoneY + safeZoneH * 0.930";
			w="safeZoneW * 0.4";
			h="safeZoneH * 0.013";
			style=0;
			text="";
			texture="";
			colorBackground[]={0,0,0,0};
			colorBar[]={0.95300001,0.898,0,1};
			colorFrame[]={0,0,0,0};
			colorText[]={0.95300001,0.898,0,1};
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			onLoad="_ctrl = _this # 0; _ctrl call PHEN_CS_fnc_StressBarInit_Other;";
		};
	};
	class Controls
	{
		class PHEN_CS_SlotBase
		{
			idc=-1;
			x="safeZoneX + safeZoneW * 1";
			y="safeZoneY + safeZoneH * 1";
			w="safeZoneW * 0.0453125";
			h="safeZoneH * 0.07685186";
			style="2048+48";
			text="";
			fixedWidth=0;
			font="PuristaMedium";
			sizeEx="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			moving="false";
			onLoad="_ctrl = _this#0; _ctrl ctrlSetTooltipMaxWidth (SafeZoneW / 2);";
			onMouseEnter="_ctrl = _this#0; _ctrl ctrlSetTooltipMaxWidth (SafeZoneW / 2);";
			shadow=1;
			tooltip="Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
			tooltipColorBox[]={0.77249998,0,0.2353,1};
			tooltipColorShade[]={0.40000001,0.40000001,0.40000001,1};
			tooltipColorText[]={0.33329999,0.91759998,0.83139998,1};
			type=1;
			colorBackground[]={1,1,1,0};
			colorBackgroundActive[]={1,1,1,0};
			colorBackgroundDisabled[]={1,1,1,0};
			colorBorder[]={0,0,0,0};
			colorDisabled[]={1,1,1,0};
			colorFocused[]={1,1,1,0};
			colorShadow[]={0,0,0,0};
			colorText[]={1,1,1,1};
			borderSize=0;
			offsetPressedX=0;
			offsetPressedY=0;
			offsetX=0;
			offsetY=0;
			soundClick[]=
			{
				"PHEN_Cybernetics\sounds\UITouchscreenSubmitButton",
				0.090000004,
				1
			};
			soundEnter[]=
			{
				"PHEN_Cybernetics\sounds\UITouchScreenGlassButton.wav",
				0.090000004,
				1
			};
			soundEscape[]={};
			soundPush[]=
			{
				"PHEN_Cybernetics\sounds\UITouchscreenSweep",
				0.090000004,
				1
			};
			onMouseButtonClick="";
			onMouseExit="";
			onSetFocus="";
		};
		class FC_0: PHEN_CS_SlotBase
		{
			idc=100;
			x="safeZoneX + safeZoneW * 0.22708334";
			y="safeZoneY + safeZoneH * 0.15925926";
		};
		class FC_1: PHEN_CS_SlotBase
		{
			idc=101;
			x="safeZoneX + safeZoneW * 0.28072917";
			y="safeZoneY + safeZoneH * 0.15925926";
		};
		class FC_2: PHEN_CS_SlotBase
		{
			idc=102;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.15925926";
		};
		class OS_0: PHEN_CS_SlotBase
		{
			idc=200;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.24722223";
		};
		class CS_0: PHEN_CS_SlotBase
		{
			idc=300;
			x="safeZoneX + safeZoneW * 0.22708334";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class CS_1: PHEN_CS_SlotBase
		{
			idc=301;
			x="safeZoneX + safeZoneW * 0.28125";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class CS_2: PHEN_CS_SlotBase
		{
			idc=302;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class IS_0: PHEN_CS_SlotBase
		{
			idc=400;
			x="safeZoneX + safeZoneW * 0.28072917";
			y="safeZoneY + safeZoneH * 0.52037038";
		};
		class IS_1: PHEN_CS_SlotBase
		{
			idc=401;
			x="safeZoneX + safeZoneW * 0.33697917";
			y="safeZoneY + safeZoneH * 0.52037038";
		};
		class NS_0: PHEN_CS_SlotBase
		{
			idc=500;
			x="safeZoneX + safeZoneW * 0.28177084";
			y="safeZoneY + safeZoneH * 0.61296297";
		};
		class NS_1: PHEN_CS_SlotBase
		{
			idc=501;
			x="safeZoneX + safeZoneW * 0.33541667";
			y="safeZoneY + safeZoneH * 0.61296297";
		};
		class ITS_0: PHEN_CS_SlotBase
		{
			idc=600;
			x="safeZoneX + safeZoneW * 0.2265625";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
		class ITS_1: PHEN_CS_SlotBase
		{
			idc=601;
			x="safeZoneX + safeZoneW * 0.28072917";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
		class ITS_2: PHEN_CS_SlotBase
		{
			idc=602;
			x="safeZoneX + safeZoneW * 0.33333334";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
		class OPS_0: PHEN_CS_SlotBase
		{
			idc=700;
			x="safeZoneX + safeZoneW * 0.61666667";
			y="safeZoneY + safeZoneH * 0.24722223";
		};
		class SK_0: PHEN_CS_SlotBase
		{
			idc=800;
			x="safeZoneX + safeZoneW * 0.61614584";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class SK_1: PHEN_CS_SlotBase
		{
			idc=801;
			x="safeZoneX + safeZoneW * 0.67083334";
			y="safeZoneY + safeZoneH * 0.4";
		};
		class H_0: PHEN_CS_SlotBase
		{
			idc=900;
			x="safeZoneX + safeZoneW * 0.61666667";
			y="safeZoneY + safeZoneH * 0.52037038";
		};
		class A_0: PHEN_CS_SlotBase
		{
			idc=1000;
			x="safeZoneX + safeZoneW * 0.6171875";
			y="safeZoneY + safeZoneH * 0.61296297";
		};
		class L_0: PHEN_CS_SlotBase
		{
			idc=1100;
			x="safeZoneX + safeZoneW * 0.6171875";
			y="safeZoneY + safeZoneH * 0.70555556";
		};
	};
};
class Extended_PreInit_EventHandlers
{
	class PHEN_Cybernetics_PreInit
	{
		init="call compile preprocessFileLineNumbers '\PHEN_Cybernetics\bootstrap\XEH_PreInit.sqf'";
	};
	class PHEN_Cybernetics_PreInit_settings
	{
		init="call compile preprocessFileLineNumbers '\PHEN_Cybernetics\bootstrap\Settings_PreInit.sqf'";
	};
};
class Extended_PostInit_EventHandlers
{
	class PHEN_Cybernetics_PostInit
	{
		init="call compile preprocessFileLineNumbers '\PHEN_Cybernetics\bootstrap\XEH_postInit.sqf'";
	};
};
class CfgFunctions
{
	class PHEN_Cybernetics_MainFunctions
	{
		tag="PHEN_Cybernetics";
		class TerminalActions
		{
			file="\PHEN_Cybernetics\functions";
			class AddTerminalActions
			{
			};
		};
	};
};
class CfgFactionClasses
{
	class NO_CATEGORY;
	class PHEN_Cybernetics_Modules: NO_CATEGORY
	{
		displayName="Cybernetics System";
	};
};
class cfg3Den
{
	class Object
	{
		class AttributeCategories
		{
			class StateSpecial
			{
				class Attributes
				{
					class PHEN_CS_isRipperdoc
					{
						displayName="is Ripperdoc?";
						tooltip="Should this unit be considered a Ripperdoc?";
						property="PHEN_CS_isRipperdoc";
						control="Checkbox";
						defaultValue="false";
						expression="[_this, _value] call PHEN_CS_fnc_setRipeprdoc";
						condition="objectControllable";
					};
					class PHEN_CS_Disabled
					{
						displayName="Cybernetics Disabled?";
						tooltip="Exclude this unit from the cybernetics system entirely. Blocks handler attachment, effect application, and implant installation.";
						property="PHEN_CS_Disabled";
						control="Checkbox";
						defaultValue="false";
						expression="[_this, _value] call PHEN_CS_fnc_setCyberneticsDisabled";
						condition="objectControllable";
					};
				};
			};
		};
	};
};
class CfgVehicles
{
	class Logic;
	class Module_F: Logic
	{
		class AttributesBase
		{
			class Default;
			class Edit;
			class Combo;
			class Checkbox;
			class CheckboxNumber;
			class ModuleDescription;
			class Units;
		};
		class ModuleDescription
		{
			class AnyStaticObject;
		};
	};
	class PHEN_Cybernetics_ModuleAddTerminalActions: Module_F
	{
		scope=2;
		displayName="Create RipperDoc Station";
		icon="\PHEN_Cybernetics\Data\PHEN_Cybernetics_Station.paa";
		category="PHEN_Cybernetics_Modules";
		function="PHEN_Cybernetics_fnc_AddTerminalActions";
		functionPriority=1;
		isGlobal=2;
		isTriggerActivated=1;
		isDisposable=1;
		is3DEN=1;
		curatorCanAttach=0;
		class ModuleDescription: ModuleDescription
		{
			description[]=
			{
				"3DEN module execution for adding actions to manage the Cybernetics for players",
				"Sync the module to the object that should have the Actions."
			};
			sync[]=
			{
				"AnyStaticObject"
			};
		};
	};
	class WeaponHolder;
	class Item_Base_F: WeaponHolder
	{
	};
	class PHEN_CS_Item_LowLightOptics_MkI: Item_Base_F
	{
		scope=1;
		scopeCurator=1;
		displayName="Low-Light Optics Mk.I";
		picture="\PHEN_Cybernetics\Data\ocular_2_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_2_ca.paa";
		author="Phenosi";
		editorCategory="EdCat_Equipment";
		editorSubcategory="EdSubcat_InventoryItems";
		vehicleClass="Items";
		model="\A3\Weapons_F\DummyNVG.p3d";
		class TransportItems
		{
			class PHEN_CS_LowLightOptics_MkI
			{
				name="PHEN_CS_LowLightOptics_MkI";
				count=1;
			};
		};
	};
	class PHEN_CS_Item_LowLightOptics_MkII: Item_Base_F
	{
		scope=1;
		scopeCurator=1;
		displayName="Low-Light Optics Mk.II";
		picture="\PHEN_Cybernetics\Data\ocular_4_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_4_ca.paa";
		author="Phenosi";
		editorCategory="EdCat_Equipment";
		editorSubcategory="EdSubcat_InventoryItems";
		vehicleClass="Items";
		model="\A3\Weapons_F\DummyNVG.p3d";
		class TransportItems
		{
			class PHEN_CS_LowLightOptics_MkII
			{
				name="PHEN_CS_LowLightOptics_MkII";
				count=1;
			};
		};
	};
	class PHEN_CS_Item_LowLightOptics_MkIII: Item_Base_F
	{
		scope=1;
		scopeCurator=1;
		displayName="Low-Light Optics Mk.III";
		picture="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		author="Phenosi";
		editorCategory="EdCat_Equipment";
		editorSubcategory="EdSubcat_InventoryItems";
		vehicleClass="Items";
		model="\A3\Weapons_F\DummyNVG.p3d";
		class TransportItems
		{
			class PHEN_CS_LowLightOptics_MkIII
			{
				name="PHEN_CS_LowLightOptics_MkIII";
				count=1;
			};
		};
	};
	class PHEN_CS_Item_LowLightOptics_MkIV: Item_Base_F
	{
		scope=1;
		scopeCurator=1;
		displayName="Argus Combat Optics Mk.IV";
		picture="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		author="Phenosi";
		editorCategory="EdCat_Equipment";
		editorSubcategory="EdSubcat_InventoryItems";
		vehicleClass="Items";
		model="\A3\Weapons_F\DummyNVG.p3d";
		class TransportItems
		{
			class PHEN_CS_LowLightOptics_MkIV
			{
				name="PHEN_CS_LowLightOptics_MkIV";
				count=1;
			};
		};
	};
};
class CfgWeapons
{
	class NVGoggles;
	class PHEN_CS_LowLightOptics_MkI: NVGoggles
	{
		scope=1;
		author="Phenosi";
		displayName="Low-Light Optics Mk.I";
		picture="\PHEN_Cybernetics\Data\ocular_2_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_2_ca.paa";
		descriptionShort="Cybernetic ocular implant. Grants low-light night vision capability.";
		descriptionUse="Sub-retinal photonic amplifier. Surgically implanted ocular enhancement granting enhanced low-light sensitivity and active night vision. Requires implantation by a licensed Ripperdoc.";
		visionMode[]=
		{
			"Normal",
			"NVG"
		};
		thermalMode[]={5,6};
		model="\A3\Weapons_f\DummyNVG";
		modelOptics="\A3\weapons_f\reticle\optics_empty.p3d";
		class ItemInfo
		{
			type=616;
			uniformModel="";
			modelOff="";
			mass=1;
		};
	};
	class PHEN_CS_LowLightOptics_MkII: PHEN_CS_LowLightOptics_MkI
	{
		picture="\PHEN_Cybernetics\Data\ocular_4_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_4_ca.paa";
		displayName="Low-Light Optics Mk.II";
		descriptionShort="Cybernetic ocular implant. Grants thermal imaging capability.";
		descriptionUse="Upgraded sensor suite with an integrated thermal imaging array. Detects heat signatures through smoke, foliage, and light cover. Requires implantation by a licensed Ripperdoc.";
		visionMode[]=
		{
			"Normal",
			"TI"
		};
	};
	class PHEN_CS_LowLightOptics_MkIII: PHEN_CS_LowLightOptics_MkI
	{
		picture="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		displayName="Low-Light Optics Mk.III";
		descriptionShort="Cybernetic ocular implant. Grants combined night vision and thermal imaging.";
		descriptionUse="Fully integrated multi-spectrum ocular array. Combines night vision amplification and thermal imaging into a single implant for maximum situational awareness in any conditions. Requires implantation by a licensed Ripperdoc.";
		visionMode[]=
		{
			"Normal",
			"NVG",
			"TI"
		};
	};
	class PHEN_CS_LowLightOptics_MkIV: PHEN_CS_LowLightOptics_MkI
	{
		picture="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		icon="\PHEN_Cybernetics\Data\ocular_3_ca.paa";
		displayName="Argus Combat Optics Mk.IV";
		descriptionShort="Cybernetic ocular implant. Grants combat sensor suite, night vision, and thermal imaging.";
		descriptionUse="Integrated Argus combat ocular array with view-gated mine recognition, allied-unit tracking, medical telemetry, approximate pre-fire aim prediction, radar scale control, night vision, and thermal imaging. Requires implantation by a licensed Ripperdoc.";
		visionMode[]=
		{
			"Normal",
			"NVG",
			"TI"
		};
	};
};
class CfgSounds
{
	class PHEN_CS_SomeOverclockImpactSound
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\OverclockImpactSound.ogg",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_Glitch_Digital_Bleep
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\GlitchDigitalBleep.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_Glitch_Laser_Scanning
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\GlitchLaserScanning.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_Texture_Optical_Attack
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\TextureOpticalAttack.wss",
			0.5,
			1
		};
		titles[]={};
	};
	class PHEN_CS_Texture_Virus_Detected_Alarm
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\TextureVirusDetectedAlarm.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Data_Flow
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIDataFlow.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Encryptor_App_Close
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIEncryptorAppClose.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Encryptor_App_Open
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIEncryptorAppOpen.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Hologram_Close
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIHologramClose.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Hologram_Open
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIHologramOpen.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_HUD_Loading_Data
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIHUDLoadingData.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_HUD_Notification
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIHUDNotification.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_HUD_Screen_Scrolling
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIHUDScreenScrolling.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Hud_Window_Close
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIHudWindowClose.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Hud_Window_Open
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIHudWindowOpen.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Login_Verified
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UILoginVerified.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Message_Bleep
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIMessageBleep.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Micro_App_Close
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIMicroAppClose.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Micro_App_Open
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIMicroAppOpen.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_QR_Code_Reader
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIQRCodeReader.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Smart_System_Activation
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemActivation.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Smart_System_Closing_App
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemClosingApp.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Smart_System_Loading_Data
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemLoadingData.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Smart_System_Transferring_Data
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemTransferringData.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Touch_Screen_Glass_Button
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UITouchScreenGlassButton.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Touchscreen_Submit_Button
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UITouchscreenSubmitButton.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Touchscreen_Sweep
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UITouchscreenSweep.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Window_Close
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIWindowClose.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Window_Open
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIWindowOpen.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_UI_Zappy_Pop_Up
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\UIZappyPopUp.wss",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_BioMedica_Scan
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\BioMedica_scan_0.ogg",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_BioMedica_GeneralHeal
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\BioMedica_GeneralHeal_0.ogg",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_BioMedica_Defib_0
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\BioMedica_Defib_0.ogg",
			1,
			1
		};
		titles[]={};
	};
	class PHEN_CS_BioMedica_Defib_1
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\BioMedica_Defib_1.ogg",
			1,
			1
		};
		titles[]={};
	};
	class Dash_1
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\Dash_1.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Dash_2
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\Dash_2.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Dash_3
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\Dash_3.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class AirDash_1
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\AirDash_1.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class AirDash_2
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\AirDash_2.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class AirDash_3
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\AirDash_3.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Jump_1
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\Jump_1.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Jump_2
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\Jump_2.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Jump_3
	{
		sound[]=
		{
			"PHEN_Cybernetics\sounds\Jump_3.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
};
class CfgSFX
{
	class PHEN_CS_Glitch_Digital_Bleep
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\GlitchDigitalBleep.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_Glitch_Laser_Scanning
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\GlitchLaserScanning.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_Texture_Optical_Attack
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\TextureOpticalAttack.wss",
			1,
			0.5,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_Texture_Virus_Detected_Alarm
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\TextureVirusDetectedAlarm.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Data_Flow
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIDataFlow.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Encryptor_App_Close
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIEncryptorAppClose.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Encryptor_App_Open
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIEncryptorAppOpen.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Hologram_Close
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIHologramClose.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Hologram_Open
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIHologramOpen.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_HUD_Loading_Data
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIHUDLoadingData.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_HUD_Notification
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIHUDNotification.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_HUD_Screen_Scrolling
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIHUDScreenScrolling.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Hud_Window_Close
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIHudWindowClose.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Hud_Window_Open
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIHudWindowOpen.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Login_Verified
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UILoginVerified.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Message_Bleep
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIMessageBleep.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Micro_App_Close
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIMicroAppClose.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Micro_App_Open
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIMicroAppOpen.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_QR_Code_Reader
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIQRCodeReader.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Smart_System_Activation
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemActivation.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Smart_System_Closing_App
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemClosingApp.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Smart_System_Loading_Data
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemLoadingData.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Smart_System_Transferring_Data
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UISmartSystemTransferringData.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Touch_Screen_Glass_Button
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UITouchScreenGlassButton.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Touchscreen_Submit_Button
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UITouchscreenSubmitButton.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Touchscreen_Sweep
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UITouchscreenSweep.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Window_Close
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIWindowClose.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Window_Open
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIWindowOpen.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
	class PHEN_CS_UI_Zappy_Pop_Up
	{
		sound0[]=
		{
			"PHEN_Cybernetics\sounds\UIZappyPopUp.wss",
			1,
			1,
			50,
			1,
			0,
			0,
			0
		};
		sounds[]=
		{
			"sound0"
		};
		empty[]=
		{
			"",
			0,
			0,
			0,
			0,
			0,
			0,
			0
		};
	};
};
class cfgMods
{
	author="Phenosi";
	timepacked="1777910290";
};
