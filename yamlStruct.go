package main

type TestConfiguration struct {
	Flavours []string
}

type YamlDescriptor struct {
	Title         string
	Description   string
	Icon          string
	Configuration []string
	Test          TestConfiguration
}
