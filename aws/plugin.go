package aws

import (
	"fmt"
	"net/http"
	"time"

	"github.com/google/go-jsonnet"
	"github.com/marcbran/jpoet/pkg/jpoet"
)

const defaultRequestTimeout = 30 * time.Second

type EndpointResolver func(svc *Service, region string) (string, error)

type Config struct {
	Client      *http.Client
	Endpoint    EndpointResolver
	Credentials CredentialsByRequest
	registry    *registry
	pluginOpts  []jpoet.PluginOption
}

type Option func(*Config)

func WithServices(services ...Definition) Option {
	return func(c *Config) {
		c.registry.definitions = append(c.registry.definitions, services...)
	}
}

func WithCredentialsByRequest(credentialsFor CredentialsByRequest) Option {
	return func(c *Config) {
		if credentialsFor == nil {
			return
		}
		c.Credentials = credentialsFor
	}
}

func WithEndpointResolver(resolver EndpointResolver) Option {
	return func(c *Config) {
		c.Endpoint = resolver
	}
}

func WithHTTPClient(client *http.Client) Option {
	return func(c *Config) {
		if client == nil {
			return
		}
		c.Client = client
	}
}

func WithPluginOption(opt jpoet.PluginOption) Option {
	return func(c *Config) {
		c.pluginOpts = append(c.pluginOpts, opt)
	}
}

func WithMiddleware(middleware ...jpoet.Middleware) Option {
	return WithPluginOption(jpoet.WithMiddleware(middleware...))
}

func WithHook(hook jpoet.InvokeHook) Option {
	return WithPluginOption(jpoet.WithHook(hook))
}

func DefaultEndpoint(svc *Service, region string) (string, error) {
	if svc.Global() {
		return svc.GlobalEndpoint, nil
	}
	if region == "" {
		return "", fmt.Errorf("%s requires a region", svc.Key)
	}
	return fmt.Sprintf("https://%s.%s.amazonaws.com", svc.EndpointPrefix, region), nil
}

func Plugin(opts ...Option) *jpoet.Plugin {
	cfg := &Config{
		Client: &http.Client{
			Timeout: defaultRequestTimeout,
		},
		Endpoint:    DefaultEndpoint,
		Credentials: noCredentials,
		registry:    &registry{},
	}
	for _, o := range opts {
		o(cfg)
	}
	return jpoet.NewPlugin("aws", []jsonnet.NativeFunction{
		Call(cfg),
	}, cfg.pluginOpts...)
}
