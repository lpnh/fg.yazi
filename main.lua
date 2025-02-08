local shell = os.getenv("SHELL"):match(".*/(.*)")
local get_cwd = ya.sync(function() return cx.active.current.cwd end)
local fail = function(s, ...) ya.notify { title = "fg", content = string.format(s, ...), timeout = 5, level = "error" } end

local cmd_tbl = {
	rg = {
		grep = "rg --color=always --line-number --smart-case",
		prev = "--preview='bat --color=always --highlight-line={2} {1}' --preview-window=~3,+{2}+3/2,up,66%",
		prompt = "--prompt='rg> '",
		extra = function(cmd_grep)
			local logic = {
				default = { cond = "[[ ! $FZF_PROMPT =~ rg ]] &&", op = "||" },
				fish = { cond = 'not string match -q "*rg*" $FZF_PROMPT; and', op = "; or" },
			}
			local lgc = logic[shell] or logic.default
			local extra_bind = "--bind='ctrl-f:transform:%s "
				.. [===[echo "rebind(change)+change-prompt(rg> )+disable-search+clear-query+reload:%s {q}" %s ]===]
				.. [===[echo "unbind(change)+change-prompt(fzf> )+enable-search+clear-query+reload:%s \" \" "']===]
			return string.format(extra_bind, lgc.cond, cmd_grep, lgc.op, cmd_grep)
		end,
	},
	rga = {
		grep = "rga --color=always --files-with-matches --smart-case",
		prev = "--preview='rga --context 5 --no-messages --pretty {q} {}' --preview-window=up,66%",
		prompt = "--prompt='rga> '",
	},
}

local fzf_from = function(job_args)
	local cmd = cmd_tbl[job_args]
	if not cmd then
		return fail("`%s` is not a valid argument. use rg or rga instead", job_args)
	end

	local fzf_tbl = {
		"fzf",
		"--ansi",
		"--delimiter=:",
		"--disabled",
		"--layout=reverse",
		"--no-multi",
		"--nth=3..",
		cmd.prompt,
		string.format("--bind='start:reload:%s {q}'", cmd.grep),
		string.format("--bind='change:reload:sleep 0.1; %s {q} || true'", cmd.grep),
		cmd.prev,
		"--bind='ctrl-w:change-preview-window(80%|66%)'",
		"--bind='ctrl-\\:change-preview-window(right|up)'",
	}

	if cmd.extra then
		table.insert(fzf_tbl, cmd.extra(cmd.grep))
	end

	return table.concat(fzf_tbl, " ")
end

local function entry(_, job)
	local _permit = ya.hide()
	local args = fzf_from(job.args[1])
	local cwd = tostring(get_cwd())

	local child, err = Command(shell)
		:args({ "-c", args })
		:cwd(cwd)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Command failed with error code %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then -- unreachable?
		return fail("Cannot read command output, error code %s", err)
	elseif output.status.code == 130 then -- interrupted with <ctrl-c> or <esc>
		return
	elseif output.status.code == 1 then -- no match
		return ya.notify { title = "fg", content = "No file selected", timeout = 5 }
	elseif output.status.code ~= 0 then -- anything other than normal exit
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")
	if target ~= "" then
		local colon_pos = string.find(target, ":")
		local file_url = colon_pos and string.sub(target, 1, colon_pos - 1) or target

		ya.manager_emit("reveal", { file_url })
	end
end

return { entry = entry }
