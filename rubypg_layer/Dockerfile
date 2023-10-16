FROM public.ecr.aws/lambda/ruby:3.2

RUN yum install -y amazon-linux-extras \
    && amazon-linux-extras enable postgresql14 \
    && yum group install "Development Tools" -y

RUN yum install -y postgresql postgresql-devel

CMD "/bin/bash"