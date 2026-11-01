//go:build e2e

package tests

import "testing"

func TestPublishedServicePackagesAreUpToDate(t *testing.T) {
	for _, service := range []string{"ecr", "ec2"} {
		t.Run(service, func(t *testing.T) {
			given, when, then := scenario(t)

			given.
				the_published_service_directory(service)

			when.
				the_nodes_are_generated()

			then.
				there_is_no_error().and().
				the_generated_package_matches_the_published_one()
		})
	}
}
