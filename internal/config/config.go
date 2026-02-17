package config

import "github.com/spf13/viper"

type Config struct {
	Language     string
	Framewok     string
	Architecture string
	ProjectDir   string
}

func LoadConfig() (*Config, error) {
	viper.SetConfigName("archy")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("$HOME/.archy")
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		return nil, err
	}

	cfg := &Config{}
	viper.Unmarshal(cfg)
	return cfg, nil

}
