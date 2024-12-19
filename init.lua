local shell = os.getenv("SHELL"):match(".*/(.*)")

local preview_opts = {
	default = [===[line={2} && begin=$( if [[ $line -lt 7 ]]; then echo $((line-1)); else echo 6; fi ) && bat --highlight-line={2} --color=always --line-range $((line-begin)):$((line+10)) {1}]===],
	fish = [[set line {2} && set begin ( test $line -lt 7  &&  echo (math "$line-1") || echo  6 ) && bat --highlight-line={2} --color=always --line-range (math "$line-$begin"):(math "$line+10") {1}]],
	nu = [[let line = ({2} | into int); let begin = if $line < 7 { $line - 1 } else { 6 }; bat --highlight-line={2} --color=always --line-range $'($line - $begin):($line + 10)' {1}]],
}
local preview_cmd = preview_opts[shell] or preview_opts.default

local rg_prefix = "rg --column --line-number --no-heading --color=always --smart-case "
local rga_prefix =
	"rga --files-with-matches --color ansi --smart-case --max-count=1 --no-messages --hidden --follow --no-ignore --glob '!.git' --glob !'.venv' --glob '!node_modules' --glob '!.history' --glob '!.Rproj.user' --glob '!.ipynb_checkpoints' "

local fzf_args = [[fzf --preview='bat --color=always {1}']]
local rg_args = {
	default = [[fzf --ansi --disabled --bind "start:reload:]]
		.. rg_prefix
		.. [[{q}" --bind "change:reload:sleep 0.1; ]]
		.. rg_prefix
		.. [[{q} || true" --delimiter : --preview ']]
		.. preview_cmd
		.. [[' --preview-window 'up,60%' --nth '3..']],
	nu = [[fzf --ansi --disabled --bind "start:reload:]]
		.. rg_prefix
		.. [[{q}" --bind "change:reload:sleep 100ms; try { ]]
		.. rg_prefix
		.. [[{q} }" --delimiter : --preview ']]
		.. preview_cmd
		.. [[' --preview-window 'up,60%' --nth '3..']],
}
local rga_args = {
	default = [[fzf --ansi --disabled --layout=reverse --sort --header-first --header '---- Search inside files ----' --bind "start:reload:]]
		.. rga_prefix
		.. [[{q}" --bind "change:reload:sleep 0.1; ]]
		.. rga_prefix
		.. [[{q} || true" --delimiter : --preview 'rga --smart-case --pretty --context 5 {q} {}' --preview-window 'up,60%' --nth '3..']],
	nu = [[fzf --ansi --disabled --layout=reverse --sort --header-first --header '---- Search inside files ----' --bind "start:reload:]]
		.. rga_prefix
		.. [[{q}" --bind "change:reload:sleep 100ms; try { ]]
		.. rga_prefix
		.. [[{q} }" --delimiter : --preview 'rga --smart-case --pretty --context 5 {q} {}' --preview-window 'up,60%' --nth '3..']],
}
local fg_args = [[rg --color=always --line-number --no-heading --smart-case '' | fzf --ansi --preview=']]
	.. preview_cmd
	.. [[' --delimiter=':' --preview-window='up:60%' --nth='3..']]

local function split_and_get_first(input, sep)
	if sep == nil then
		sep = "%s"
	end
	local start, _ = string.find(input, sep)
	if start then
		return string.sub(input, 1, start - 1)
	end
	return input
end

local state = ya.sync(function() return cx.active.current.cwd end)

local function fail(s, ...) ya.notify { title = "fg", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry(_, job)
	local _permit = ya.hide()
	local cwd = tostring(state())
	local cmd_args = ""

	if job.args[1] == "fzf" then
		cmd_args = fzf_args
	elseif job.args[1] == "rg" then
		cmd_args = rg_args[shell] or rg_args.default
	elseif job.args[1] == "rga" then
		cmd_args = rga_args[shell] or rga_args.default
	else
		cmd_args = fg_args
	end

	local child, err = Command(shell)
		:args({ "-c", cmd_args })
		:cwd(cwd)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Spawn command failed with error code %s.", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read `fzf` output, error code %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")

	local file_url = split_and_get_first(target, ":")

	if file_url ~= "" then
		ya.manager_emit(file_url:match("[/\\]$") and "cd" or "reveal", { file_url })
	end
end

return { entry = entry }
