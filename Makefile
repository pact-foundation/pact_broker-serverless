downloadpb:
	rm -rf pact_broker && curl -L https://api.github.com/repos/pact-foundation/pact-broker-docker/tarball | tar xz --wildcards --strip=1 */pact_broker

downloadpbmac:
	rm -rf pact_broker && curl -L https://api.github.com/repos/pact-foundation/pact-broker-docker/tarball | tar xz --strip=1 */pact_broker

packagewithpg:
	./build-withpg.sh

package:
	./build-withpglayer.sh

buildpglayer:
	cd rubypg_layer && ./build.sh

deploypglayer:
	cd rubypg_layer && npm run deploy -v

logs:
	awslogs get /aws/lambda/pact-broker-serverless-dev-api --profile=${AWS_PROFILE_NAME} 

deploy:
	npm run deploy
