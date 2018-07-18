Facter.add('lxd') do
  setcode do
    {
      'socket' => 'unix:///var/lib/lxd/unix.socket'
    }
  end
end

