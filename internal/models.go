package internal

type TestConfiguration struct {
	Flavours []string
}

type YamlDescriptor struct {
	Title           string
	Description     string
	Icon            string
	Configuration   []string
	Test            TestConfiguration
	Platforms       []string
	Deprecation     string
	RequiresVersion bool `yaml:"requiresVersion"`
}
