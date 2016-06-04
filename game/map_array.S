/* The map of the world as a big array of chunks (road components + possibly other stuff like bushes etc.) 

/*
 * Each chunk is A x B in size (TBA)
 * The whole map is C x D (TBA) which is (C*D)/(A*B) chunks
 * Each byte is a number which corresponds to one of the following map chunks:
 *
 * 0:    nothing (concrete ground)
 *
 * 1:    road - straight - 0 degrees
 * 2:    road - straight - 45 degrees
 * 3:    road - straight - 90 degrees
 * 4:    road - straight - 135 degrees
 *
 * 901:  road - 90 degree curve - top left corner
 * 902:  road - 90 degree curve - top right corner
 * 903:  road - 90 degree curve - bottom right corner
 * 904:  road - 90 degree curve - bottom left corner
 *
 * 451:  road - 45 degree curve - top left corner
 * 452:  road - 45 degree curve - top right corner
 * 453:  road - 45 degree curve - bottom right corner
 * 454:  road - 45 degree curve - bottom left corner
 *
 * 4501: road - 45 degree curve filler - top left corner
 * 4502: road - 45 degree curve filler - top right corner
 * 4503: road - 45 degree curve filler - bottom left corner
 * 4504: road - 45 degree curve filler - bottom right corner
 *
 * Objects:
 *
 * 9991: bush
 * 9992: tree
 *
 * Any other number is treated as 0
 */

/* Currently this map is a simple round loop track with a tree in the middle */

.align
map_array:
  .byte 901, 3   , 902
  .byte 1  , 9992, 1
  .byte 904, 3   , 903
