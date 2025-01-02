function bplus_food_jokers_tooltip()
  local nodes = {}
  local centers = {}
  for _, center in pairs(G.P_CENTERS) do
    if center.bplus_food_joker then
      centers[#centers + 1] = center
    end
  end

  local text = {}
  local function add_line(line)
    local parts = {}
    for _, part in ipairs(line) do
      parts[#parts + 1] = { n = G.UIT.T, config = { text = part[1], colour = part[2] or G.C.GREY, scale = 0.33 } }
    end
    text[#text + 1] = {
      n = G.UIT.R,
      config = { align = "cm" },
      nodes = parts,
    }
  end

  local cur_line = {}
  local cur_length = 0
  for i, center in ipairs(centers) do
    local name = localize({ type = "name_text", set = "Joker", key = center.key })
    cur_line[#cur_line + 1] = { name, G.C.ORANGE }
    cur_length = cur_length + #name + 2

    if i == #centers then
      break
    end

    if cur_length > 15 then
      cur_line[#cur_line + 1] = { "," }
      add_line(cur_line)
      cur_line = {}
      cur_length = 0
    else
      cur_line[#cur_line + 1] = { ", " }
    end
  end

  if #cur_line > 0 then
    add_line(cur_line)
  end

  nodes[#nodes + 1] = {
    n = G.UIT.C,
    nodes = text,
  }

  return nodes
end

function bplus_is_blackjack(cards)
  local aces = 0
  local total = 0
  for _, card in ipairs(cards) do
    local id = card:get_id()
    local value = 0
    if id > 10 and id < 14 then
      value = 10
    elseif id == 14 then
      value = 11
      aces = aces + 1
    elseif id > 1 and id < 11 then
      value = id
    end

    if card.debuff then
      value = 0
    end

    total = total + value
  end

  while total > 21 and aces > 0 do
    total = total - 10
    aces = aces - 1
  end

  return total == 21
end

function bplus_open_pack(key, from_tag)
  stop_use()
  local card = Card(
    G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2,
    G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2,
    G.CARD_W * 1.27,
    G.CARD_H * 1.27,
    G.P_CARDS.empty,
    G.P_CENTERS[key],
    { bypass_discovery_center = true, bypass_discovery_ui = true }
  )
  card.cost = 0
  card.from_tag = from_tag
  G.FUNCS.use_card({ config = { ref_table = card } })
  card:start_materialize()
end

function bplus_get_editions()
  local editions = {}
  for key, center in pairs(G.P_CENTERS) do
    local key = key:match("^e_(.+)")
    if key and key ~= "base" then
      editions[#editions + 1] = key
    end
  end
  return editions
end

function bplus_random_seal(seed_key)
  return pseudorandom_element({
    "Red",
    "Blue",
    "Purple",
    "Gold",
  }, pseudoseed(seed_key))
end

function bplus_random_enhancement(seed_key)
  local enhancements = {}
  for key, center in pairs(G.P_CENTERS) do
    if key:match "m_.+" then
      enhancements[#enhancements + 1] = center
    end
  end
  return pseudorandom_element(enhancements, pseudoseed(seed_key))
end

function bplus_create_food_joker(seed_key)
  local _pool, _pool_key = get_current_pool("Joker", nil, nil, seed_key)
  local keys = {}
  for _, key in ipairs(_pool) do
    if key ~= "UNAVAILABLE" then
      local center = G.P_CENTERS[key]
      if center.bplus_food_joker then
        keys[#keys + 1] = center.key
      end
    end
  end

  if not next(keys) then
    keys = { "j_popcorn" }
  end

  return create_card(
    'Joker',
    G.jokers,
    nil,
    nil,
    nil,
    nil,
    pseudorandom_element(keys, pseudoseed(_pool_key)),
    'top'
  )
end

function bplus_most_played_poker_hand()
  local _planet, _hand, _tally = nil, nil, 0
  for _, handname in ipairs(G.handlist) do
    if G.GAME.hands[handname].visible and G.GAME.hands[handname].played > _tally then
      _hand = handname
      _tally = G.GAME.hands[handname].played
    end
  end
  return _hand
end

function bplus_tag_loc_vars(self, infoq)
  local loc_vars = {}
  if self.name == 'Investment Tag' then
    loc_vars = { self.config.dollars }
  elseif self.name == 'Handy Tag' then
    loc_vars = { self.config.dollars_per_hand, self.config.dollars_per_hand * (G.GAME.hands_played or 0) }
  elseif self.name == 'Garbage Tag' then
    loc_vars = { self.config.dollars_per_discard, self.config.dollars_per_discard * (G.GAME.unused_discards or 0) }
  elseif self.name == 'Juggle Tag' then
    loc_vars = { self.config.h_size }
  elseif self.name == 'Top-up Tag' then
    loc_vars = { self.config.spawn_jokers }
  elseif self.name == 'Skip Tag' then
    loc_vars = { self.config.skip_bonus, self.config.skip_bonus * ((G.GAME.skips or 0) + 1) }
  elseif self.name == 'Orbital Tag' then
    loc_vars = {
      (self.ability.orbital_hand == '[' .. localize('k_poker_hand') .. ']') and self.ability.orbital_hand or
      localize(self.ability.orbital_hand, 'poker_hands'), self.config.levels }
  elseif self.name == 'Economy Tag' then
    loc_vars = { self.config.max }
  elseif type(self.loc_vars) == "function" then
    local ret = self:loc_vars(infoq)
    if ret and ret.vars then
      loc_vars = ret.vars
    end
  end
  return loc_vars
end
