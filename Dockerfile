FROM lambci/lambda:build-ruby2.5

RUN yum install -y postgresql postgresql-devel 
RUN yum install -y postgresql postgresql-devel mysql-devel

ADD pact_broker/Gemfile /var/task/Gemfile
ADD pact_broker/Gemfile.lock /var/task/Gemfile.lock

RUN bundle install && bundle install --deployment