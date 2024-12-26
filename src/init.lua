BalatroPlus = {
  path = SMODS.current_mod.path:gsub("/$", ""),
  load_chace = {},
  G = {},
}

function BalatroPlus.load(path)
  local module = BalatroPlus.load_chace[path]
  if not module then
    module = assert(SMODS.load_file("src/" .. path .. ".lua"))()
    BalatroPlus.load_chace[path] = module
  end
  return module
end

BalatroPlus.load("override")
BalatroPlus.load("utils")

BalatroPlus.load("joker")("jokers", {
  -- Common
  "pickpocket",
  "archeologist",
  "memory_card",
  "golden_cheese",
  "zombie_hand",
  "ufo",
  "shopping_bill",
  "calculator",
  "boxer",
  "blackjack",
  "treasure_map",

  -- Uncommon
  "four_leaf_clover",
  "jim130",
  "santa_claus",
  "hungry",
  "magnifying_glass",
  "anonymous_mask",
  "toilet",

  -- Rare
  "crown",
  "space_invader",
})

BalatroPlus.load("deck")("decks", {
  "purple",
  "illusion",
  "jokered",
})

BalatroPlus.load("blind")("blinds", {
  "extra",
  "hammer",
  "loop",
  "low",
  "thunder",
})

BalatroPlus.load("tag")("tags", {
  "glow",
  "glove",
  "dish",
  "collector",
  "booster",
  "bounty",
})

BalatroPlus.load("consumable")("consumables", {
  "sigil",
})
