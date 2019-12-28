{ name =
	"nonbili-postgres"
, dependencies =
	[ "aff"
	, "aff-promise"
	, "argonaut-codecs"
	, "effect"
	, "console"
	, "psci-support"
	]
, packages =
	./packages.dhall
, sources =
	[ "src/**/*.purs", "test/**/*.purs" ]
}