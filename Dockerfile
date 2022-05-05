FROM lambci/lambda:build-ruby2.7

RUN yum install -y postgresql postgresql-devel mysql-devel sqlite-devel

ADD pact_broker/Gemfile /var/task/Gemfile
ADD pact_broker/Gemfile.lock /var/task/Gemfile.lock
# hack because pg isnt pinned
RUN sed -i 's/gem "pg", "~>1.0"/gem "pg", "1.2.3"/g' /var/task/Gemfile
RUN bundle install && bundle install --deployment