FROM public.ecr.aws/lambda/ruby:3.2

RUN yum install -y amazon-linux-extras \
    && amazon-linux-extras enable postgresql14 \
    && yum group install "Development Tools" -y

RUN yum install -y postgresql postgresql-devel mysql-devel

ADD pact_broker/Gemfile /var/task/Gemfile
# ADD pact_broker/Gemfile.lock /var/task/Gemfile.lock
# hack because pg isnt pinned
# RUN sed -i 's/gem "pg", "~>1.5"/gem "pg", "1.5.4"/g' /var/task/Gemfile
RUN bundle install && bundle install --deployment