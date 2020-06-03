# Configure here #
instance_uuid="UUID"
export TRITON_URL="https://us-central-1.api.mnx.io"
export TRITON_ACCOUNT="USERNAME"

# How many to keep. This will depend on how often you run the cron. This will remove snapshots older than this many count
keep_count=2

# log file location
log_file="/var/log/snapshot.log"





# DON'T TOUCH AFTER HERE
export TRITON_PROFILE="env"
unset TRITON_USER
export TRITON_KEY_ID="$(ssh-keygen -l -f $HOME/.ssh/id_rsa.pub | awk '{print $2}')"
unset TRITON_TESTING
unset TRITON_PROFILE
keep=$(expr $keep_count + 1)

exec >> "${log_file}"
exec 2>&1

echo "==== STARTED $(date +'%Y%m%d_%H%M') ===="
triton instance snapshot create -w --name="$(date +'%s')" "${instance_uuid}"

# Get snapshots older than you keep_count
for snap_name in $(triton instance snapshot list "${instance_uuid}" | sed -n '1!p' | sort -nr -k1 | awk '{ print $1 }' | tail -n +${keep}); do
        triton instance snapshot delete -f -w "${instance_uuid}" "${snap_name}"
done
echo "==== FINISHED $(date +'%Y%m%d_%H%M') ===="
echo ""

unset TRITON_KEY_ID
unset TRITON_ACCOUNT
unset TRITON_URL
