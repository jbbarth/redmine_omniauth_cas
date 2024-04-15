require_dependency 'user'

class User < Principal
  Kernel::silence_warnings { MAIL_LENGTH_LIMIT = 80 }
end

