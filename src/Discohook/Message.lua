local Message = {}
Message.__index = Message

local Author = require(script.Parent.Author)
local User = require(script.Parent.User)
local Embed = require(script.Parent.Embed)
local Reaction = require(script.Parent.Reaction)
local MessageFlags = require(script.Parent.MessageFlags)

function Message.new(data)
	local self = setmetatable({}, Message)
	
	self.id = data.id
	self.messageType = data["type"]
	self.content = data.content
	self.channelId = data.channel_id
	self.author = Author.new(data.author)
	self.embeds = {}
	self.reactions = {}
	self.mentions = {}
	self.mentionRoles = {}
	self.pinned = data.pinned
	self.mentionEveryone = data.mentionEveryone
	self.tts = data.tts
	self.timestamp = data.timestamp
	self.flags = MessageFlags.fromBitfield(data.flags)
	self.webhookId = data.webhook_id
	
	if data.embeds then
		for _, embedData in data.embeds do
			local embed = Embed.new(embedData.title, embedData.description, embedData.url)
			
			if embedData.color then
				local r = bit32.band((bit32.rshift(embedData.color, (8 * 2))), 0xFF)
				local g = bit32.band((bit32.rshift(embedData.color, (8 * 1))), 0xFF)
				local b = bit32.band((bit32.rshift(embedData.color, (8 * 0))), 0xFF)
				
				embed:setColor(Color3.fromRGB(r, g, b))
			end
			
			if embedData.timestamp then
				embed:setTimestamp(embedData.timestamp)
			end
			
			if embedData.footer then
				embed:setFooter(embedData.footer.text, embedData.footer.icon_url) 
				
				embed.footer.proxy_icon_url = embedData.footer.proxy_icon_url
			end
			
			if embedData.image then 
				embed:setImage(embedData.image.url)
				
				embed.image.height = embedData.image.height
				embed.image.width = embedData.image.width
				embed.image.proxy_url = embedData.image.proxy_icon_url
			end
			
			if embedData.thumbnail then
				embed:setThumbnail(embedData.thumbnail.url, embedData.thumbnail.height, embedData.thumbnail.width, embedData.footer.proxy_url)
				
				embed.thumbnail.height = embedData.thumbnail.height
				embed.thumbnail.width = embedData.thumbnail.width
				embed.thumbnail.proxy_url = embedData.thumbnail.proxy_url
			end
			
			if embedData.author then 
				embed:setAuthor(embedData.author.name, embedData.author.url, embedData.author.icon_url, embedData.footer.proxy_icon_url)
				embed.author.proxy_url = embedData.author.proxy_icon_url
			end
			
			
			if embedData.fields then
				for _, field in embedData.fields do
					embed:addField(field.name, field.value, field.inline)
				end
			end
		
			table.insert(self.embeds, embed)
		end
	end	
	
	if data.mentions then
		for _, mentionData in data.mentions do
			table.insert(self.mentions, User.new(mentionData))
		end
	end	
	
	if data.mentionRoles then
		for _, roleMentionData in data.mentionRoles do
			table.insert(self.mentionRoles, roleMentionData)
		end
	end	
	
	if data.reactions then
		for _, reactionData in data.reactions do
			table.insert(self.reactions, Reaction.new(reactionData))
		end
	end
	
	return self
end

return Message