#import "Tweak.h"

float get_memory() {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    if(kerr == KERN_SUCCESS) {
        return ((float)info.resident_size / 1024.0f / 1024.0f);
    } else {
        return -1.0f;
    }
}
NSString* return_memory() {
    float memory = get_memory();

    if (memory != -1) {
        return [NSString stringWithFormat:@"Memory usage (in megabytes): %.4f", memory];
    } else {
        return @"Error retrieving memory usage.";
    }
}
void report_memory() {
    log(@"%@", return_memory());
}
void print_backtrace() {
    void* array[24];
    size_t size;
    char **strings;
    size_t i;
    
    size = backtrace(array, 24);
    strings = backtrace_symbols(array, size);
    
    debug(@"Begin stack trace:");
    for(int i = 0; i < size; i++) {
        debug(@"%s",strings[i]);
    }
    debug(@"End stack trace.");
    
    free(strings);
}

// PPPlaneType planeType(PPPlaneInfo* plane) {
//     debug(@"planeType(%@)", plane);
//     if(plane.cargoRows == 0) return PPPassengerPlaneType;
//     else if(plane.passRows == 0) return PPCargoPlaneType;
//     else return PPMixedPlaneType;
// }
