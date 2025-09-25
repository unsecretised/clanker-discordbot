import discord_gleam/types/slash_command
import dot_env as dot
import dot_env/env
import gleam/option

import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import logging

pub fn main() -> Nil {
  echo "Bot is starting..."
  dot.new()
  |> dot.set_path(".env")
  |> dot.set_debug(False)
  |> dot.load()

  echo "Environment initialized"

  let assert Ok(bot_token) = env.get_string("BOT_TOKEN")
  let assert Ok(client_id) = env.get_string("CLIENT_ID")

  logging.configure()
  logging.set_level(logging.Info)

  let vote_cmd =
    slash_command.SlashCommand(
      name: "ping",
      description: "returns pong",
      options: [
        slash_command.CommandOption(
          name: "test",
          description: "string yummy",
          type_: slash_command.StringOption,
          required: False,
        ),
      ],
    )
  let bot = discord_gleam.bot(bot_token, client_id, intents.all())

  let assert Ok(_) = discord_gleam.register_global_commands(bot, [vote_cmd])
  discord_gleam.run(bot, [event_handler])

  Nil
}

fn event_handler(bot, packet: event_handler.Packet) {
  case packet {
    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Got message: " <> message.d.content)

      case message.d.content {
        "!ping" -> {
          case
            discord_gleam.send_message(bot, message.d.channel_id, "Pong!", [])
          {
            Ok(_) -> Nil
            Error(_) -> {
              logging.log(logging.Error, "Error sending message")
              Nil
            }
          }

          Nil
        }

        _ -> Nil
      }
    }
    event_handler.GuildMemberAddPacket(member) -> {
      let user = member.d.guild_member.user.id

      echo user
      {
        case
          discord_gleam.send_message(
            bot,
            "1392444888586518540",
            "<@" <> user <> "> joined the server",
            [],
          )
        {
          Ok(_) -> Nil
          Error(_) -> {
            logging.log(logging.Error, "Error sending message")
            Nil
          }
        }

        Nil
      }
    }
    event_handler.InteractionCreatePacket(interaction) -> {
      logging.log(logging.Info, "Got interaction: " <> interaction.d.data.name)

      case interaction.d.data.name {
        "ping" -> {
          case interaction.d.data.options {
            option.Some(options) -> {
              todo
            }
            _ -> Nil
          }

          Nil
        }
        _ -> Nil
      }
    }

    _ -> Nil
  }
}
