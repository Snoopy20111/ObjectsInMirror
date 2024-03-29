class_name AK

class EVENTS:

	const MUS_CINE_INTRO_04 = 2294462436
	const ACTR_ENTITY_PANIC_PLAY = 245490600
	const ACTR_CAR_TIRES_STOP = 2101812367
	const ACTR_CAR_IMPACT_HURT = 2286104131
	const ACTR_TRAIN_STOP = 1990425139
	const UI_STARTGAME = 2467171692
	const UI_LOGOPARADE = 1599283196
	const AMB_MENU = 2552542987
	const AMB_CINE_INTRO_02 = 1751074331
	const UI_NAV_HOVER = 503177270
	const ACTR_CAR_IMPACT_TAP = 3647900047
	const MUS_MENU = 3149643052
	const ACTR_ENTITY_PANIC_STOP = 2623160858
	const ACTR_CAR_ENGINE_PLAY = 495721106
	const UI_NAV_ACCEPT = 1225797752
	const UI_NAV_UNHOVER = 2336382113
	const ACTR_CAR_ENGINE_STOP = 2207278604
	const MUS_CINE_INTRO_01 = 2294462433
	const ACTR_CAR_IMPACT_DEATH = 511688286
	const ACTR_TRAIN_PLAY = 3823428949
	const AMB_CINE_INTRO_01 = 1751074328
	const ACTR_TRAIN_HORN = 1536965356
	const MUS_CINE_INTRO_03 = 2294462435
	const PLAY_TEST = 3187507146
	const MUS_CINE_INTRO_02 = 2294462434
	const ACTR_CAR_TIRES_PLAY = 579292521
	const ACTR_TRAINCROSSING_PLAY = 3691794637
	const ACTR_TRAINCROSSING_STOP = 514021403

	const _dict = {
		"MUS_Cine_Intro_04": MUS_CINE_INTRO_04,
		"ACTR_Entity_Panic_Play": ACTR_ENTITY_PANIC_PLAY,
		"ACTR_Car_Tires_Stop": ACTR_CAR_TIRES_STOP,
		"ACTR_Car_Impact_Hurt": ACTR_CAR_IMPACT_HURT,
		"ACTR_Train_Stop": ACTR_TRAIN_STOP,
		"UI_StartGame": UI_STARTGAME,
		"UI_LogoParade": UI_LOGOPARADE,
		"AMB_Menu": AMB_MENU,
		"AMB_Cine_Intro_02": AMB_CINE_INTRO_02,
		"UI_Nav_Hover": UI_NAV_HOVER,
		"ACTR_Car_Impact_Tap": ACTR_CAR_IMPACT_TAP,
		"MUS_Menu": MUS_MENU,
		"ACTR_Entity_Panic_Stop": ACTR_ENTITY_PANIC_STOP,
		"ACTR_Car_Engine_Play": ACTR_CAR_ENGINE_PLAY,
		"UI_Nav_Accept": UI_NAV_ACCEPT,
		"UI_Nav_Unhover": UI_NAV_UNHOVER,
		"ACTR_Car_Engine_Stop": ACTR_CAR_ENGINE_STOP,
		"MUS_Cine_Intro_01": MUS_CINE_INTRO_01,
		"ACTR_Car_Impact_Death": ACTR_CAR_IMPACT_DEATH,
		"ACTR_Train_Play": ACTR_TRAIN_PLAY,
		"AMB_Cine_Intro_01": AMB_CINE_INTRO_01,
		"ACTR_Train_Horn": ACTR_TRAIN_HORN,
		"MUS_Cine_Intro_03": MUS_CINE_INTRO_03,
		"Play_Test": PLAY_TEST,
		"MUS_Cine_Intro_02": MUS_CINE_INTRO_02,
		"ACTR_Car_Tires_Play": ACTR_CAR_TIRES_PLAY,
		"ACTR_TrainCrossing_Play": ACTR_TRAINCROSSING_PLAY,
		"ACTR_TrainCrossing_Stop": ACTR_TRAINCROSSING_STOP
	}

class STATES:

	class ISALIVE:
		const GROUP = 3036050140

		class STATE:
			const DEAD = 2044049779
			const HURTING = 3686962126
			const NONE = 748895195
			const ALMOST_DEAD = 2890830352
			const ALIVE = 655265632

	const _dict = {
		"IsAlive": {
			"GROUP": 3036050140,
			"STATE": {
				"Dead": 2044049779,
				"Hurting": 3686962126,
				"None": 748895195,
				"Almost_Dead": 2890830352,
				"Alive": 655265632
			}
		}
	}

class SWITCHES:

	class TRAIN_DISTANCE:
		const GROUP = 3242222673

		class SWITCH:
			const CLOSE = 1451272583
			const DISTANT = 2142610728

	const _dict = {
		"Train_Distance": {
			"GROUP": 3242222673,
			"SWITCH": {
				"Close": 1451272583,
				"Distant": 2142610728
			}
		}
	}

class GAME_PARAMETERS:

	const THROTTLE = 2995819693
	const RPM = 796049864
	const SPEED = 640949982
	const IMPACTFORCE = 1642941132
	const PANIC_VERB_VOLUME = 394958007
	const PANIC = 3130232582
	const TIRESCREECH = 3266676374
	const TRAIN_DISTANCE = 3242222673

	const _dict = {
		"Throttle": THROTTLE,
		"RPM": RPM,
		"Speed": SPEED,
		"ImpactForce": IMPACTFORCE,
		"Panic_Verb_Volume": PANIC_VERB_VOLUME,
		"Panic": PANIC,
		"TireScreech": TIRESCREECH,
		"Train_Distance": TRAIN_DISTANCE
	}

class TRIGGERS:

	const _dict = {}

class BANKS:

	const INIT = 1355168291
	const MASTER = 4056684167

	const _dict = {
		"Init": INIT,
		"Master": MASTER
	}

class BUSSES:

	const MASTER_AUDIO_BUS = 3803692087
	const PLAYER = 1069431850
	const UI = 1551306167
	const ENTITIES = 2083370804
	const ENTITIES_PANIC = 3671883448
	const AMB = 1117531639
	const TRAIN = 3412057565
	const SFX = 393239870

	const _dict = {
		"Master Audio Bus": MASTER_AUDIO_BUS,
		"Player": PLAYER,
		"UI": UI,
		"Entities": ENTITIES,
		"Entities_Panic": ENTITIES_PANIC,
		"AMB": AMB,
		"Train": TRAIN,
		"SFX": SFX
	}

class AUX_BUSSES:

	const PANIC_VERB = 2055051794
	const MASTER_VERB = 2722806429

	const _dict = {
		"Panic_Verb": PANIC_VERB,
		"Master_Verb": MASTER_VERB
	}

class AUDIO_DEVICES:

	const NO_OUTPUT = 2317455096
	const SYSTEM = 3859886410

	const _dict = {
		"No_Output": NO_OUTPUT,
		"System": SYSTEM
	}

class EXTERNAL_SOURCES:

	const _dict = {}

