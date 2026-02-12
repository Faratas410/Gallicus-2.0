# UI Sprite Assignment Audit (Global)

## Summary

* Total scenes scanned: 15
* Non-compliant Buttons: 0
* Non-compliant Labels/RichTextLabels: 54
* Runtime factory gaps: 3

## Scenes — Main/Menu Scope

### scenes/Main.tscn

* Reachable from entry: yes
* Instanced by: entry scene (`res://scenes/Main.tscn`)
* Buttons missing official states:

  * None
* Labels/RichTextLabels missing background wrapper:

  * None

## Scenes — Run/HUD Scope

### scenes/UI.tscn

* Reachable from entry: yes
* Instanced by: scenes/Main.tscn (PackedScene instance)
* Buttons missing official states:

  * None
* Labels/RichTextLabels missing background wrapper:

  * HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeText/BetBadgeTitle (type: Label)
    Notes: parent is VBoxContainer, not a background wrapper node.
  * HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeText/BetBadgeValue (type: Label)
  * UI_RunRoot/DebugOverlay/Lbl_DebugOverlay (type: RichTextLabel)
  * UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_TITLE (type: Label)
  * UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_BODY (type: Label)
  * UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_TITLE (type: Label)
  * UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_BODY (type: Label)
  * UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Lbl_MID_CHOICE_TITLE (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_TITLE (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_SUBTITLE (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_HINT (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/SeedRow/Lbl_INTRO_BODY (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/StakeRow/Lbl_INTRO_BODY_STAKE (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow/Lbl_INTRO_FOOTER (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BuyTokenRow/BuyTokenVBox/Lbl_INTRO_CHOICE_0 (type: Label)
  * UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BuyTokenRow/Lbl_INTRO_CHOICE_1 (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_TITLE (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_BODY (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_SUBTITLE (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_HINT (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_FOOTER (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Lbl_PUSH_YOUR_LUCK_CHOICE_0 (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Lbl_PUSH_YOUR_LUCK_CHOICE_1 (type: Label)
  * UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICE (type: Label)
  * UI_RunRoot/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailTitle (type: Label)
  * UI_RunRoot/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailText (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_TITLE (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_SUBTITLE (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_BODY (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_HINT (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_PACTS_TITLE (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_PACTS_BODY (type: RichTextLabel)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_CONDANNE_TITLE (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_CONDANNE_BODY (type: RichTextLabel)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_TITLE (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_BODY (type: Label)
  * UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL/Box_END_RUN_MARGIN/Lbl_END_RUN_FOOTER (type: RichTextLabel)

## Scenes — Popups/Overlays

### scenes/UI.tscn

* Reachable from entry: yes
* Instanced by: scenes/Main.tscn (PackedScene instance)
* Buttons missing official states:

  * None
* Labels/RichTextLabels missing background wrapper:

  * HUD/ScarPopupPanel/ScarPopupMargin/ScarPopup (type: RichTextLabel)
  * HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceTitle (type: Label)
  * HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceRule (type: Label)
  * HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceDoom (type: Label)

### scenes/ui/BettingCircle.tscn

* Reachable from entry: yes
* Instanced by: scripts/ui/ui_root.gd::open_bet_circle
* Buttons missing official states:

  * None
* Labels/RichTextLabels missing background wrapper:

  * ContractPanel/ContractVBox/TitleLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/BetNameLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/CondannaLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/CondizioneLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/PattoLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/BetNameLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/CondannaLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/CondizioneLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/PattoLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/BetNameLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/CondannaLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/CondizioneLabel (type: Label)
  * ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/PattoLabel (type: Label)

## Scenes — Other/Secondary Screens

### legacy_runtime/pickups/Pickup_Coins.tscn

* Reachable from entry: unknown
* Instanced by: legacy_runtime/pickups/PickupSpawner.gd::_spawn_pickup
* Buttons missing official states:

  * None
* Labels/RichTextLabels missing background wrapper:

  * None

### legacy_runtime/pickups/Pickup_Heal.tscn

* Reachable from entry: unknown
* Instanced by: legacy_runtime/pickups/PickupSpawner.gd::_spawn_pickup
* Buttons missing official states:

  * None
* Labels/RichTextLabels missing background wrapper:

  * None

### legacy_runtime/pickups/Pickup_SpeedBoost.tscn

* Reachable from entry: unknown
* Instanced by: legacy_runtime/pickups/PickupSpawner.gd::_spawn_pickup
* Buttons missing official states:

  * None
* Labels/RichTextLabels missing background wrapper:

  * None

## Runtime Factory Gaps

* scripts/ui/main_menu.gd::_build_condanne_list — creates Label without official background wrapper; reachable from scripts/ui/main_menu.gd::_show_achievements
* scripts/ui/main_menu.gd::_add_museo_header — creates Label without official background wrapper; reachable from scripts/ui/main_menu.gd::_build_museo_list
* scripts/ui/main_menu.gd::_add_museo_item — creates Label without official background wrapper; reachable from scripts/ui/main_menu.gd::_build_museo_list
