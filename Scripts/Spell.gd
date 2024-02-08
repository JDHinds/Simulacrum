class_name Spell extends Node

enum spellDamageType {aether, fire, air, water, earth, quicksilverMind, saltBody, sulfurSoul, primaMateria}
enum spellPlanetaryModifier {leadSaturn, tinJupiter, ironMars, goldSun, copperVenus, quicksilverMercurary, silverMoon}
enum spellMundaneModifier {acid, astimony, arsenic, bismuth, cobalt, salAmmoniac, aquaFortis, aquaRegia, aquaVitae}
enum spellSchool {C, D, E, F, G, A, B}
	
const spellDamageTypeSymbol = ["🜀","🜂","🜁","🜄","🜃","☿","🜍","🜔", "🜎"]
const spellPlanetaryModifierSymbol = ["🜪","🜩","🜜","🜚","🜠","🜍","🜛"]
const spellMundandModifierSymbol = ["🜊", "♁", "🜺", "♆", "🜶", "🜹", "🜅", "🜆", "🜉"]

var school
var damageType
var spellName
var planetaryModifier
var mundaneModifier
	
func cast():
	var spellModel = MeshInstance3D.new()
	spellModel.mesh = TextMesh.new()
	spellModel.mesh.text = spellDamageTypeSymbol[damageType]
